#' Measure defoliation events in host trees
#' @description Conduct host/nonhost comparison to identify defoliation events
#'
#' @param host_tree a data.frame rwl object containing the tree-level growth series for all
#' host trees to be compared to the non-host chronology
#' @param nonhost_chron a data.frame rwl object comtaining a single non-host chronology
#' @param duration_years the mimimum number of years in which to consider a defolation event
#' @param max_reduction the minimum level of tree growth to be considered in defoliation
#' @param list_output defaults to \code{FALSE}. This option is to output a long list object containing a separate data.frame for each series in
#' \code{host_tree} that includes the input series and the \code{nonhost_chron}, the corrected series, and
#' the character string identifying the defoliation events.
#'
#' @return a list object with elements containing data.frame rwl objects of the host and non-host series, corrected
#'
#' @export

defoliate_trees <- function(host_tree, nonhost_chron, duration_years = 8, max_reduction = -1.28, list_output = FALSE) {
  if(ncol(nonhost_chron) > 1) stop("nonhost_chron can only contain 1 series")
  if(max_reduction > 0) max_reduction <- max_reduction * -1
  host_tree <- data.frame(host_tree)
  nonhost_chron <- data.frame(nonhost_chron)
  nseries <- ncol(host_tree)
  tree_list <- lapply(seq_len(nseries), function(i){
    input_series <- na.omit(dplR::combine.rwl(host_tree[, i, drop=FALSE], nonhost_chron))
    corrected_series <- correct_host_series(input_series)
    defoliated_series <- id_defoliation(corrected_series, duration_years = duration_years, max_reduction = max_reduction)
    return(defoliated_series)
    }
  )
  if (list_output) return(tree_list)
  else return(stack_defoliation(tree_list))
}


