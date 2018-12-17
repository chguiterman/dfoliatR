#' Graph individual tree-ring series from a 'defol' object
#'
#' @param x a 'defol' object
#' @param show_index Identify the timeseries index to plot. Options include the corrected or normalized index values. Defaults to \code{norm_index}.
#' @param col_defol the color of verticle bars indicating defoliation years
#'
#' @export

plot_defol <- function(x, show_index = c("cor_index", "norm_index"), col_defol = 'black') {
  if(!is.defol(x)) stop("'x' must be a 'defol' object")
  if(length(show_index) == 2) show_index <- "norm_index"
  defol_events <- x[!is.na(x$defol_status), ]
  p <- ggplot2::ggplot(data = x, ggplot2::aes_string(x="year", y=show_index, group="series"))
  p <- (p + ggplot2::geom_hline(yintercept = 0) + ggplot2::geom_line())
  p <- (p + ggplot2::geom_bar(data = defol_events,
                              ggplot2::aes_string(x="year", y=show_index), stat="identity",
                              fill = col_defol))
  p <- (p + ggplot2::facet_grid(series ~ .))
  p <- (p + ggplot2::theme_bw())
  p
}

#' Produce a stacked plot to present composited, site-level insect outbreak chronologies
#'
#' @param x an 'outbreak' object produced by \code{outbreak}
#'
#' @export

plot_outbreak <- function(x){
  if(!is.outbreak(x)) stop("'x' must be an 'outbreak' object")

  outbrk_events <- x[! is.na(x$outbreak_status), ]

  # setup plot
  p <- ggplot2::ggplot(data = x, ggplot2::aes_string(x="year"))

  # extract minor axes
  foo <- p + ggplot2::geom_line(ggplot2::aes_string(y="mean_index"))
  minor_labs <- ggplot2::ggplot_build(foo)$layout$panel_params[[1]]$x.minor_source

  # top plot
  index <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_hline(yintercept = 0, colour = "grey80") +
    ggplot2::geom_line(ggplot2::aes_string(y="mean_index")) +
    ggplot2::geom_bar(data = outbrk_events, ggplot2::aes_string(x="year", y="mean_index"), stat="identity") +
    ggplot2::scale_y_continuous(name = "Growth index") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"),
          axis.title.x=ggplot2::element_blank(),
          axis.text.x=ggplot2::element_blank(),
          axis.ticks.x=ggplot2::element_blank())

  # mid plot
  prop <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_ribbon(ggplot2::aes_string(ymax="percent_defol_trees", ymin=0)) +
    ggplot2::scale_y_continuous(name = "% defoliated") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"),
          axis.title.x=ggplot2::element_blank(),
          axis.text.x=ggplot2::element_blank(),
          axis.ticks.x=ggplot2::element_blank())

  # bottom plot
  line <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_line(ggplot2::aes_string(y="num_trees")) +
    ggplot2::scale_y_continuous(name = "Sample depth") +
    ggplot2::scale_x_continuous(name = "Year") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"))

  # combine
  ggpubr::ggarrange(index, prop, line, nrow=3, align = "v")
}
