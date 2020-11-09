#'Identify defoliation events in host trees
#'
#'[defoliate_trees()] is the starting point for most analyses of insect
#'defoliation signals preserved in the growth patterns of trees. It requires
#'individual-tree standardized measurements from potential host trees and a
#'tree-ring chronology from a nearby non-host species. First,
#'[defoliate_trees()] combines these tree-ring indices by calling [gsi()] to
#'perform a "correction" of the host-tree indices to remove the climatic
#'influences on tree growth as represented by the non-host chronology. This
#'should isolate a disturbance-related signal. Second, [defoliate_trees()], runs
#'[id_defoliation()], which completes a runs analyses to evaluate sequences of
#'negative departures in the host tree growth series (`ngsi`) for potential
#'defoliation events.
#'
#'@param host_tree A `dplR::rwl` object containing the tree-level growth series
#'  for all host trees to be compared to the non-host chronology.
#'
#'@param nonhost_chron A `dplR::rwl` object containing a single non-host
#'  chronology. If blank, defoliation events will be inferred on the host_tree
#'  series as provided. It is incumbent on the user to ensure the host_tree
#'  series are properly prepared for analyses when there is no nonhost_chron
#'  provided.
#'
#'@inheritParams id_defoliation
#'
#'@param list_output Defaults to `FALSE`. This option is to output a long list
#'  object containing a separate data.frame for each series in `host_tree` that
#'  includes the input series and the `nonhost_chron`, the corrected series, and
#'  the character string identifying the defoliation events.
#'
#'@return By default this returns a long-form data frame of tree-level growth
#'  suppression indices and identified defoliation events. If `list_output =
#'  TRUE`, it returns a list object with each element containing a data.frame
#'  rwl object of the host and non-host series, plus the outputs from [gsi()].
#'  The list object is useful for assessing the effects of running [gsi()] on
#'  the host and nonhost data.
#'
#'@note Other functions in `dfoliatR`, like [outbreak()] and [plot_defol()],
#'  require a long-form data frame identifiable as a [defol()] object. Selecting
#'  `list_output = TRUE` will trigger errors in running other functions.
#'
#'@importFrom rlang .data :=
#'@importFrom magrittr %>%
#'@importFrom glue glue
#'@importFrom tibble rownames_to_column
#'@importFrom tibble column_to_rownames
#'@importFrom stats na.omit
#'
#'@examples
#'# Load host and non-host data
#'data("dmj_h") # Host trees
#'data("dmj_nh") # Non-host chronology
#'
#'dmj_defol <- defoliate_trees(dmj_h, dmj_nh)
#'
#'
#'@export
defoliate_trees <- function(host_tree, nonhost_chron = NULL,
                            duration_years = 8,
                            max_reduction = -1.28,
                            bridge_events = FALSE,
                            series_end_event = FALSE,
                            list_output = FALSE) {

  nonhost_chron <- data.frame(nonhost_chron)

  # If there is a nonhost chronology
  if (ncol(nonhost_chron) > 1) stop("nonhost_chron can only contain 1 series")
  if (max_reduction > 0) max_reduction <- max_reduction * -1

  host_tree <- data.frame(host_tree)
  nseries <- ncol(host_tree)
  tree_list <- lapply(seq_len(nseries), function(i) {
    input_series <-
      stats::na.omit(
        dplR::combine.rwl(
          host_tree[, i, drop = FALSE],
          nonhost_chron)
      )

   #If there is no nonhost chronology
    if (nrow(nonhost_chron) > 0) corrected_series <- gsi(input_series)
    else corrected_series <- host_tree %>%
      rownames_to_column(var = "year") %>%
      select(.data$year, colnames(host_tree)[i]) %>%
      na.omit() %>%
      mutate(nonhost = NA,
             nonhost_rescale = NA,
             !!glue("{colnames(host_tree)[i]}_gsi") :=
               .data[[colnames(host_tree)[i]]],
             !!glue("{colnames(host_tree)[i]}_ngsi") :=
               scale(.data[[glue("{colnames(host_tree)[i]}_gsi")]])
      ) %>%
      column_to_rownames(var = "year")

    defoliated_series <- id_defoliation(corrected_series,
                                        duration_years = duration_years,
                                        bridge_events = bridge_events,
                                        max_reduction = max_reduction,
                                        series_end_event = series_end_event)
    return(defoliated_series)
    }
  )
  if (list_output) return(tree_list)
  else return(stack_defoliation(tree_list))
}


#' Composite defoliation series to determine outbreak events
#'
#' [outbreak()] takes a `defol` object from
#' [defoliate_trees()] and composites it into a site-level object.
#' Function parameters allow the user to filter the tree-level series in various
#' ways to optimize thresholds of what constitutes an "outbreak" level event
#' recorded by the host trees.
#'
#' @param x a defol object
#'
#' @param filter_perc the minimum percentage of defoliated trees to be
#'   considered an outbreak. Default is 25 percent.
#'
#' @param filter_min_series The minimum number of trees required for an outbreak
#'   event. Default is 3 trees.
#'
#' @param filter_min_defol The minimum number of trees recording a defoliation
#'   event. Default is 1 tree.
#'
#' @return A data.frame `obr` object for the site that includes all trees in the
#'   host `defol` object. Columns in the `obr` include:
#'
#'   \enumerate{ \item `year` for every year in the set of host trees, \item
#'   `num_defol` the number of trees recording a defoliation event, \item
#'   `percent_defol` the percent of trees recording a defoliation, \item
#'   `num_max_defol` the number of trees recording a maximum growth suppression
#'   (or peak of that event on that tree), \item `perc_max_defol` the percent of
#'   trees at maximum defoliation, \item `mean_gsi` the average of all trees
#'   growth suppression index (`gsi`), \item `mean_ngsi` the average of all
#'   trees normalized growth suppression index (`ngsi`), \item `outbreak_status`
#'   whether that year constitutes an outbreak based on the filters applied to
#'   the function.}
#'
#' @examples
#' data("dmj_defol")
#' head(outbreak(dmj_defol))
#'
#' @importFrom rlang .data quos
#' @importFrom magrittr %>%
#' @importFrom dplyr group_by summarize summarize_at n_distinct
#' inner_join case_when filter
#'
#' @export
outbreak <- function(x,
                     filter_perc = 25,
                     filter_min_series = 3,
                     filter_min_defol = 1) {
  if (!is.defol(x))
    stop("x must be a defol object")
  defol_events <-
    c("defol", "max_defol", "bridge_defol", "series_end_defol")
  x <- group_by(x, .data$year)
  counts <- x %>%
    summarize(samp_depth = n_distinct(.data$series),
              num_defol = sum(.data$defol_status %in% defol_events),
              perc_defol = round(.data$num_defol / .data$samp_depth * 100, 1),
              num_max_defol = sum(.data$defol_status %in% "max_defol"),
              perc_max_defol =
                round(.data$num_max_defol / .data$samp_depth * 100, 1)
    )
  mean_gsi <- x %>%
    summarize_at(c("mean_gsi" = quos(.data$gsi),
                   "mean_ngsi" = quos(.data$ngsi)),
                        ~ mean(., na.rm = TRUE) %>%
                          round(., 4))
  out <- inner_join(counts, mean_gsi, by = "year") %>%
    mutate(outbreak_status = case_when(
      (.data$perc_defol >= filter_perc) &
        (.data$samp_depth >= filter_min_series) &
        (.data$num_defol >= filter_min_defol)
      ~ "outbreak",
      TRUE ~ "not_obr"
    ))

  if (any("series_end_defol" %in% x$defol_status)) {
    ev <- events_table(out$outbreak_status, "outbreak") %>%
      filter(.data$starts == max(.data$starts))
    if (all(((nrow(out) - ev$ends) < 3) &
         (out[ev$ends : nrow(out), ]$num_defol > 0))) {
      out[ev$starts : nrow(out), "outbreak_status"] <- "se_outbreak"
    }
  }
  as_obr(out)
}
