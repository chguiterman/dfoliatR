#' Composite defoliation series to determine outbreak events
#'
#' @param x a defol object
#' @param comp_name the desired series name for the outbreak composite
#' @param filter_prop the minimum proportion of defoliated trees to be considered an outbreak. Default is 0.25.
#' @param filter_min_series The minimum number of trees required for an outbreak event. Default is 3 trees

outbreak <- function(x, comp_name = "comp", filter_prop = 0.25, filter_min_series = 3){
  if(!is.defol(x)) stop("x must be a defol object")
  defol_events <- c("defoliated", "max_defoliation")
  event_count <- as.data.frame(table(year = subset(x, x$defol_status %in% defol_events)$year))
  series_count <- sample_depth(x)
  counts <- merge(event_count, series_count,
                  by = 'year')
  counts$prop <- counts$Freq / counts$samp_depth
  filter_mask <- (counts$prop >= filter_prop) & (counts$samp_depth >= filter_min_series)
  comp_years <- subset(counts, filter_mask)$year
  event_years <- data.frame(year = as.integer(levels(comp_years)[comp_years]),
                            defol_status = "outbreak")
  comp <- merge(counts, event_years, by = "year", all = TRUE)
  series_cast <- reshape2::dcast(x, year ~ series, value.var = "value")
  series_cast$mean <- rowMeans(series_cast[, -1], na.rm=TRUE)
  out <- merge(series_cast[, c("year", "mean")], comp, by = "year")
  out$series <- comp_name
  out <- out[, c('year', 'series', 'samp_depth', 'Freq', 'prop', 'mean', 'defol_status')]
  names(out)[c(3:7)] <- c("num_trees", "num_defol_trees", "prop_defol_trees", "mean_index", "outbreak_status")
  class(out) <- c("outbreak", "data.frame")
  return(out)
}



#' Calculate the sample depth of a host series data.frame
#'
#' @param x An rwl object.
#' @return A data.frame containing the years and number of trees
#'
#' @export
#'
sample_depth <- function(x) {
  if(!is.defol(x)) stop("x must be a defol object")
  x_stats <- series_stats(x)
  n_trees <- nrow(x_stats)
  out <- data.frame(year = min(x_stats$first):max(x_stats$last))
  for(i in 1:n_trees){
    yrs <- x_stats[i, ]$first : x_stats[i, ]$last
    treespan <- data.frame(year = yrs, z = 1)
    names(treespan)[2] <- paste(x_stats$series[i])
    out <- merge(out, treespan, by=c('year'), all=TRUE)
  }
  if(n_trees > 1){
    out$samp_depth <- rowSums(out[, -1], na.rm=TRUE)
  }
  else out$samp_depth <- out[, -1]
  out <- subset(out, select=c('year', 'samp_depth'))
  return(out)
}

#' Tree-level defoliation descriptive statistics
#'
#' @param x A defol object after running \code{defoliate_trees}.
#'
#' @return A data.frame containing tree/series-level statistics.
#'
#' @export
defol_stats <- function(x) {
  if(!is.defol(x)) stop("x must be a defol object")
  plyr::ddply(x, c('series'), function(df) {
    first <- min(df$year)
    last <- max(df$year)
    years <- length(df$year)
    count <- plyr::count(df, "defol_status")
    num_defol <- count$freq[2]
    tot_defol <- sum(count$freq[c(1, 2)])
    avg_defol <- round(tot_defol / num_defol, 0)
    out <- c(first, last, years, num_defol, tot_defol, avg_defol)
    names(out) <- c("first", "last", "years", "num_events", "tot_years", "mean_duration")
    return(out)
    }
  )
}

#' Outbreak statistics
#'
#'  @param x An outbreak object after running \code{outbreak}
#'
#'  @return A data.frame with descriptive statistics for each outbreak event determined by \code{outbreak},
#'  inluding start and end years, duration, the year with the most number of trees in the outbreak and its
#'  associated tree count, and the year with the maximum growth suppression with its associated mean_index value.
#'
#'  @export
outbreak_stats <- function(x){
  if(!is.outbreak(x)) stop ("x must be an outbreak object")
  events <- rle(x$outbreak_status == "outbreak")
  events_index <- cumsum(events$lengths)
  events_pos <- which(events$values == TRUE)
  ends <- events_index[events_pos]
  newindex = ifelse(events_pos > 1, events_pos - 1, 0)
  starts <- events_index[newindex] + 1
  if (0 %in% newindex) starts = c(1,starts)
  deps <- data.frame(cbind(starts, ends))

  start_years <- x$year[starts]
  end_years <- x$year[ends]
  duration <- end_years - start_years + 1

  peaks <- data.frame(matrix(NA, ncol=4, nrow=nrow(deps)))
  names(peaks) <- c("peak_outbreak_year", "num_trees_outbreak", "peak_defol_year", "min_index")
  for(i in 1:nrow(deps)){
    ob <- ef_comp[deps$starts[i] : deps$ends[i], ]
    peaks[i, 1] <- ob[which.max(ob$num_defol_trees), ]$year
    peaks[i, 2] <- max(ob$num_defol_trees)
    peaks[i, 3] <- ob[which.min(ob$mean_index), ]$year
    peaks[i, 4] <- round(min(ob$mean_index), 3)
  }
  out <- data.frame(start = start_years, end = end_years,
                  duration = duration)
  out <- cbind(out, peaks)
  return(out)
}
