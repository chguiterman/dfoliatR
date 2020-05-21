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
#' @note If series-end-events are present, they are omitted from calculations of
#'   total event years and mean duration.
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @importFrom dplyr group_by summarize mutate left_join select
#' @importFrom purrr map map_int map_dbl
#' @importFrom tidyr nest
#' @importFrom forcats fct_count
#'
#' @examples
#' data("dmj_defol")
#' defol_stats(dmj_defol)
#'
#'
#' @export
defol_stats <- function(x) {
  if (!is.defol(x)) stop("x must be a defol object")
  left <- x %>%
    group_by(.data$series) %>%
    summarize(first = min(.data$year),
              last = max(.data$year),
              years = length(.data$year)
    )
  right <- x %>%
    group_by(.data$series) %>%
    nest() %>%
    mutate(count = map(.data$data, ~ fct_count(.x$defol_status)),
           n_events = map_int(.data$count, ~ .x[.x$f == "max_defol", ]$n),
           tot_years =
             map_dbl(.data$count,
                     ~ if (.x[.x$f == "series_end_defol", "n"] > 0) {
                       sum(.x[! .x$f %in% c("nd", "series_end_defol"), ]$n) - 1
                     }
                     else sum(.x[! .x$f %in% "nd", ]$n)),
           mean_duration =
             map_dbl(.data$count,
                     ~ if (.x[.x$f == "series_end_defol", ]$n > 0) {
                       t <- sum(.x[! .x$f %in% c("nd", "series_end_defol"), ]$n) - 1
                       n <- .x[.x$f == "max_defol", ]$n - 1
                       round(t / n, 0)
                     }
                     else {
                       t <- sum(.x[! .x$f %in% "nd", ]$n)
                       n <- .x[.x$f == "max_defol", ]$n
                       round(t / n, 0)
                     }
             )
    ) %>%
    select(-.data$data, -.data$count)
  left_join(left, right, by = "series")
}

#' Defoliation event list
#'
#' @param x a `defol` object
#'
#' @importFrom rlang .data
#'
#' @export
get_defol_events <- function(x) {
  if (!is.defol(x)) stop("x must be a defol object")
  defol_events <- c("defol", "max_defol", "bridge_defol", "series_end_defol")
  all_series <- defol_stats(x)
  event_series <- dplyr::filter(all_series, .data$n_events > 0)
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
  null_series <- dplyr::filter(all_series, .data$n_events == 0)
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
#'  determined by [outbreak()], including: \itemize{ \item{"start" -- first year
#'  of outbreak} \item{"end" -- last year of outbreak} \item{"duration" --
#'  length of outbreak (in years)} \item{"n_df_start" -- number of trees
#'  defoliated at the start} \item{"perc_df_start" -- percent of trees
#'  defoliated at the start} \item{"max_df_obr" -- maximum number of trees in
#'  the outbreak during a single year} \item{"yr_max_df" -- year with the
#'  maximum number of trees defoliated} \item{"yr_min_ngsi" -- year with the
#'  lowest mean normalized growth suppression index (NGSI)} \item{"min_gsi" --
#'  minimum growth suppression index} \item{"min_ngsi" -- minimum normalized
#'  gsi} }
#'
#'@note Certain statistics will be set to `NA` for the final
#'  outbreak event if there was an ongoing defoliation event (in which
#'  `series_end_event = TRUE` in [defoliate_trees()]). This is because the end
#'  of the outbreak remains unknown, so statistics such as duration cannot be
#'  calculated. Stastics pertaining to the start of the event are provided.
#'
#' @examples
#' data("dmj_obr")
#' outbreak_stats(dmj_obr)
#'
#'@importFrom rlang .data
#'@importFrom magrittr %>%
#'@importFrom purrr map map_dbl map2_dbl
#'@importFrom dplyr mutate select
#'
#'@export
outbreak_stats <- function(x) {
  if (!is.obr(x)) stop("x must be an `obr` object")
  tbl <- events_table(x$outbreak_status,
                      c("outbreak", "se_outbreak")) %>%
    mutate(start = map_dbl(.data$starts, ~ x[.x, ]$year),
           end = map_dbl(.data$ends, ~ x[.x, ]$year),
           duration = .data$end - .data$start + 1,
           n_df_start = map_dbl(.data$starts, ~ x[.x, ]$num_defol),
           perc_df_start =
             map_dbl(.data$starts, ~ {
               round(x[.x, ]$num_defol / x[.x, ]$samp_depth * 100,
                     1)}),
           max_df_obr =
             map2_dbl(.data$starts, .data$ends, ~ max(x[.x : .y, ]$num_defol)),
           yr_max_df =
             map2_dbl(.data$starts, .data$ends, ~ {
               ob <- x[.x : .y, ]
               ob[which.max(ob$num_defol), ]$year}),
           yr_min_ngsi =
             map2_dbl(.data$starts, .data$ends, ~ {
               ob <- x[.x : .y, ]
               ob[which.min(ob$mean_ngsi), ]$year}),
           min_gsi =
             map2_dbl(.data$starts, .data$ends, ~ {
               ob <- x[.x : .y, ]
               round(min(ob$mean_gsi), 3)}),
           min_ngsi =
             map2_dbl(.data$starts, .data$ends, ~ {
               ob <- x[.x : .y, ]
               round(min(ob$mean_ngsi), 3)})
    ) %>%
    select(-.data$starts, -.data$ends)
  # Remove features due to ongoing outbreak event
  if (any(x$outbreak_status %in% "se_outbreak")) {
    tbl[nrow(tbl), c(2, 3, 7, 8)] <- NA
  }
  tbl
}
