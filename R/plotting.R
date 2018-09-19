#' Graph individual tree-ring series from a 'defol' object
#'
#' @param x a 'defol' object
#' @param col_defol the fill color of the verticle bars indicating defoliation years
#'
#' @export


plot_defol <- function(x, col_defol = 'black') {
  if(!is.defol(x)) stop("'x' must be a 'defol' object")

  defol_events <- x[!is.na(x$defol_status), ]

  p <- ggplot2::ggplot(data = x, ggplot2::aes_string(x="year", y="value", group="series"))
  p <- (p + ggplot2::geom_hline(yintercept = 0) + ggplot2::geom_line())
  p <- (p + ggplot2::geom_bar(data = defol_events,
                              ggplot2::aes_string(x="year", y="value"), stat="identity",
                              fill = col_defol))
  p <- (p + ggplot2::facet_grid(series ~ .))
  p <- (p + ggplot2::theme_bw())
  p
}
