#' Calculate the sample depth of a defol object
#'
#' @param x A `defol` object.
#'
#' @return A data.frame containing the years and number of trees
#'
#' @examples
#' data("dmj_defol")
#' head(sample_depth(dmj_defol))
#'
#' @export
sample_depth <- function(x) {
  if (!is.defol(x)) stop("x must be a defol object")
  x_stats <- defol_stats(x)
  n_trees <- nrow(x_stats)
  out <- data.frame(year = min(x_stats$first):max(x_stats$last))
  for (i in 1:n_trees) {
    yrs <- x_stats[i, ]$first : x_stats[i, ]$last
    treespan <- data.frame(year = yrs, z = 1)
    names(treespan)[2] <- paste(x_stats$series[i])
    out <- merge(out, treespan, by = c("year"), all = TRUE)
  }
  if (n_trees > 1) {
    out$samp_depth <- rowSums(out[, -1], na.rm = TRUE)
  }
  else out$samp_depth <- out[, -1]
  out <- subset(out, select = c("year", "samp_depth"))
  return(out)
}

#' Descriptive statistics for defoliation trees
#'
#' @param x A defol object after running [defoliate_trees()].
#'
#' @return A data frame containing tree/series-level statistics.
#'
#' @examples
#' data("dmj_defol")
#' head(defol_stats(dmj_defol))
#'
#' @export
defol_stats <- function(x) {
  if (!is.defol(x)) stop("x must be a defol object")
  out <- plyr::ddply(x, c("series"), function(df) {
    first <- min(df$year)
    last <- max(df$year)
    years <- length(df$year)
    count <- plyr::count(df, "defol_status")
    if (nrow(count) == 1) { # No defols
      sts <- c(first, last, years, 0, 0, 0)
    }
    else {
      num_defol <- count[count$defol_status == "max_defol", ]$freq
      tot_defol <- sum(count[count$defol_status != "nd", ]$freq)
      avg_defol <- round(tot_defol / num_defol, 0)
      sts <- c(first, last, years, num_defol, tot_defol, avg_defol)
    }
    return(sts)
  })
  names(out) <- c("series",
                  "first",
                  "last",
                  "years",
                  "num_events",
                  "tot_years",
                  "mean_duration")
  return(out)
}

#' Defoliation event list
#'
#' @param x a `defol`` object
#'
#' @importFrom rlang .data
#'
#' @export
get_defol_events <- function(x) {
  if (!is.defol(x)) stop("x must be a defol object")
  defol_events <- c("defol", "max_defol", "bridge_defol", "series_end_defol")
  all_series <- defol_stats(x)
  event_series <- dplyr::filter(all_series, .data$num_events > 0)
  event_list <- lapply(event_series$series, function(i) {
    dat <- dplyr::filter(x, .data$series == i)
    event_tbl <- dplyr::mutate(events_table(dat$defol_status, defol_events),
                               series = i,
                               start_year = dat$year[.data$starts],
                               end_year = dat$year[.data$ends])
    event_tbl$ngsi_mean <- unlist(lapply(seq(nrow(event_tbl)), function(j) {
      period <- event_tbl[j, ]$start_year : event_tbl[j, ]$end_year
      ngsi <- dat[dat$year %in% period, ]$ngsi
      mean(ngsi, na.rm = TRUE)
    }))
    return(event_tbl)
  })
  defol_table <- do.call(rbind, event_list)
  defol_table <- dplyr::select(defol_table, -.data$starts, -.data$ends)
  null_series <- dplyr::filter(all_series, .data$num_events == 0)
  if (nrow(null_series) > 0) {
    null_tbl <- data.frame(series = null_series$series,
                           start_year = NA,
                           end_year = NA,
                           ngsi_mean = NA)
    defol_table <- rbind(defol_table, null_tbl)
  }
  defol_table[order(defol_table$series), ]
}

#'Outbreak statistics
#'
#'Summary statistics for inferred outbreaks
#'
#'@param x An [obr] object after running [outbreak()]
#'
#'@return A data frame with descriptive statistics for each outbreak event
#'  determined by [outbreak()], including:
#'  \itemize{
#'    \item{"start" -- first year of outbreak}
#'    \item{"end" -- last year of outbreak}
#'    \item{"duration" -- length of outbreak (in years)}
#'    \item{"num_trees_start" -- number of trees at the start}
#'    \item{"perc_trees_start" -- percent of trees at the start}
#'    \item{"num_trees_outbreak" -- number of trees in the outbreak}
#'    \item{"peak_outbreak_year" -- year with maximum number of trees
#'    defoliated}
#'    \item{"peak_defol_year" -- year with the lowest value mean
#'    growth suppression index}
#'    \item{"min_gsi" -- minimum growth suppression index}
#'    \item{"min_ngsi" -- minimum normalized gsi}
#'  }
#'
#'@examples
#'data(dmj_obr)
#'outbreak_stats(dmj_obr)
#'
#'@export
outbreak_stats <- function(x) {
  if (!is.obr(x)) stop("x must be an `obr` object")
  events <- rle(x$outbreak_status == "outbreak")
  events_index <- cumsum(events$lengths)
  events_pos <- which(events$values == TRUE)
  ends <- events_index[events_pos]
  newindex <-  ifelse(events_pos > 1, events_pos - 1, 0)
  starts <- events_index[newindex] + 1
  if (0 %in% newindex) starts <-  c(1, starts)
  deps <- data.frame(cbind(starts, ends))
  start_years <- x$year[starts]
  end_years <- x$year[ends]
  duration <- end_years - start_years + 1
  peaks <- data.frame(matrix(NA, ncol = 7, nrow = nrow(deps)))
  names(peaks) <- c("num_trees_start",
                    "perc_trees_start",
                    "num_trees_outbreak",
                    "peak_outbreak_year",
                    "peak_defol_year",
                    "min_gsi",
                    "min_ngsi")
  for (i in seq_len(nrow(deps))) {
    ob <- x[deps$starts[i] : deps$ends[i], ]
    peaks[i, 1] <- ob[1, ]$num_defol
    peaks[i, 2] <- ob[1, ]$perc_defol
    peaks[i, 3] <- max(ob$num_defol)
    peaks[i, 4] <- ob[which.max(ob$num_defol), ]$year
    peaks[i, 5] <- ob[which.min(ob$mean_ngsi), ]$year
    peaks[i, 6] <- round(min(ob$mean_gsi), 3)
    peaks[i, 7] <- round(min(ob$mean_ngsi), 3)
  }
  out <- data.frame(start = start_years, end = end_years,
                    duration = duration)
  out <- cbind(out, peaks)
  return(out)
}
