#' Identify defoliation events in host trees
#'
#' @param host_tree a data.frame rwl object containing the tree-level growth
#'   series for all host trees to be compared to the non-host chronology
#' @param nonhost_chron a data.frame rwl object comtaining a single non-host
#'   chronology
#' @param duration_years the mimimum number of years in which to consider a
#'   defolation event
#' @param max_reduction the minimum level of tree growth to be considered in
#'   defoliation
#'@param bridge_events Binary, defaults to \code{FALSE}. This option allows for
#'   two successive events separated by a single year to be bridged and called one
#'   event. It should be used cautiously and closely evaluated to ensure the
#'   likelihood that the two events are actually one long event.
#' @param series_end_event Binary, defaults to \code{FALSE}. This option allows
#'   the user to identify an event ocuring at the time of sampling as a
#'   defoliation event, regardless of duration. Including it will help to
#'   quantify periodicity and extent of an outbreak. This should only be used if
#'   the user has direct knowledge of an ongoing defoliation event when the
#'   trees were sampled.
#' @param list_output defaults to \code{FALSE}. This option is to output a long
#'   list object containing a separate data.frame for each series in
#'   \code{host_tree} that includes the input series and the
#'   \code{nonhost_chron}, the corrected series, and the character string
#'   identifying the defoliation events.
#'
#' @return By default this returns a long-form data.frame of tree-level growth
#'   suppression indices and identified defoliation events. If \code{list_output
#'   = TRUE}, it returns a list object with each element containing a data.frame
#'   rwl object of the host and non-host series, plus the outputs from
#'   \code{gsi}. The list object is useful for assessing the effects of running
#'   \code{gsi} on the host and nonhost data.
#'
#' @note Other functions in \code{dfoliatR}, like \code{outbreak} and
#'   \code{plot_defol}, require a long-form data.frame identifiable as a
#'   \code{defol} object. Selecting \code{list_output = TRUE} will trigger
#'   errors in running other functions.
#'
#' @export
defoliate_trees <- function(host_tree, nonhost_chron, duration_years = 8,
                            max_reduction = -1.28, bridge_events = FALSE,
                            series_end_event = FALSE, list_output = FALSE) {
  if(ncol(nonhost_chron) > 1) stop("nonhost_chron can only contain 1 series")
  if(max_reduction > 0) max_reduction <- max_reduction * -1
  # To DO: Add provision that if only host series are given, no correction is made, but series are scanned for defol_status
  host_tree <- data.frame(host_tree)
  nonhost_chron <- data.frame(nonhost_chron)
  nseries <- ncol(host_tree)
  tree_list <- lapply(seq_len(nseries), function(i){
    input_series <- stats::na.omit(dplR::combine.rwl(host_tree[, i, drop=FALSE], nonhost_chron))
    corrected_series <- gsi(input_series)
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
#' @param x a defol object
#' @param comp_name the desired series name for the outbreak composite. Defaults to "COMP"
#' @param filter_perc the minimum percentage of defoliated trees to be considered an outbreak. Default is 25 percent.
#' @param filter_min_series The minimum number of trees required for an outbreak event. Default is 3 trees.
#' @param filter_min_defol The minimum number of trees recording a defoliation event. Default is 1 tree.
#'
#' @importFrom rlang .data
#'
#' @export
outbreak <- function(x, comp_name = "COMP", filter_perc = 25, filter_min_series = 3, filter_min_defol = 1){
  if(!is.defol(x)) stop("x must be a defol object")
  series_count <- sample_depth(x)
  defol_events <- c("defol", "max_defol", "defol_bridge")
  event_count <- as.data.frame(table(year = subset(x, x$defol_status %in% defol_events)$year))
  event_count$year <- as.numeric(as.character(event_count$year))
  max_count <- as.data.frame(table(year = subset(x, x$defol_status == "max_defol")$year))
  max_count$year <- as.numeric(as.character(max_count$year))
  defol_counts <- merge(event_count, max_count, by = 'year', all=TRUE)
  names(defol_counts) <- c('year', 'num_defol', 'num_max_defol')
  counts <- merge(series_count, defol_counts, by = 'year', all=TRUE)
  counts <- dplyr::mutate(counts,
                          num_defol = replace(.data$num_defol, is.na(.data$num_defol), 0),
                          num_max_defol = replace(.data$num_max_defol, is.na(.data$num_max_defol), 0),
                          perc_defol = .data$num_defol / .data$samp_depth * 100,
                          perc_max_defol = .data$num_max_defol / .data$samp_depth *100)
  filter_mask <- (counts$perc_defol >= filter_perc) & (counts$samp_depth >= filter_min_series) & (counts$num_defol >= filter_min_defol)
  comp_years <- subset(counts, filter_mask)$year
  event_years <- data.frame(year = comp_years,
                            outbreak_status = "outbreak")
  comp <- merge(counts, event_years, by = "year", all = TRUE)
  series_cast_gsi <- reshape2::dcast(x, year ~ series, value.var = "gsi")
  series_cast_gsi$mean_gsi <- rowMeans(series_cast_gsi[, -1], na.rm=TRUE)
  series_cast_norm <- reshape2::dcast(x, year ~ series, value.var = "ngsi")
  series_cast_norm$mean_ngsi <- rowMeans(series_cast_norm[, -1], na.rm=TRUE)
  mean_series <- merge(series_cast_gsi[, c("year", "mean_gsi")],
                       series_cast_norm[, c("year", "mean_ngsi")])
  out <- merge(comp, mean_series, by = "year")
  out <- dplyr::select(out, "year", "samp_depth", "num_defol", "perc_defol",  "num_max_defol",
                       "perc_max_defol", "mean_gsi", "mean_ngsi", "outbreak_status")
  class(out) <- c("outbreak", "data.frame")
  return(out)
}
