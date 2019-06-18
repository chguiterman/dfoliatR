#' Produce a Gantt plot of individual tree-ring series to show defoliation
#' events in time
#'
#' @param x a \code{defol} object produced by \code{defoliate_trees}.
#' @param breaks a vector length two providing threshold (negative) `ngsi`
#'   values to separate minor, moderate, and severe defoliation events. If
#'   blank, the mean and 1st quartile are used.
#'
#' @importFrom rlang .data
#' @importFrom ggplot2 ggplot aes geom_segment theme_bw theme element_blank
#'
#' @export
plot_defol <- function(x, breaks){
  stopifnot(is.defol(x))
  s.stats <- defol_stats(x)
  e.stats <- get_defol_events(x)
  if(! missing(breaks)){
    break_vals <- breaks
  }
  else break_vals <- summary(e.stats$ngsi_mean)[c(2, 4)]
  e.stats$Severity <- cut(e.stats$ngsi_mean,
                          breaks = c(-Inf, break_vals[[1]], break_vals[[2]], Inf),
                          right = FALSE,
                          labels = c("Severe", "Moderate", "Minor"))
  # plot object formation
  p <- ggplot(x, aes(x = .data[[year]], y = .data[[series]]))
  p <- p + geom_segment(data = s.stats,
                                 aes(x = .data[[first]],
                                     xend = .data[[last]],
                                     y = .data[[series]],
                                     yend = .data[[series]]),
                                 linetype = 'dotted')
  p <- p + geom_segment(data = e.stats,
                                 aes(x = .data[[start_year]],
                                     xend = .data[[end_year]],
                                     y = .data[[series]],
                                     yend = .data[[series]],
                                     colour = .data[[Severity]]),
                                 linetype = 'solid',
                                 size=1.25)
  p <- p + theme_bw() +
    theme(panel.grid.major.y = element_blank(),
                   panel.grid.minor.y = element_blank(),
                   axis.title.x = element_blank(),
                   axis.title.y = element_blank(),
                   legend.title = element_blank(),
                   legend.position = "bottom")
  p
}


#' Produce a stacked plot to present composited, site-level insect outbreak
#' chronologies
#'
#' @param x an 'outbreak' object produced by \code{outbreak}
#' @param disp_index Identify the timeseries index to plot. Defaults to
#'   \code{mean_ngsi}, the average normalized growth suppression index for the
#'   site. The only other option is \code{mean_gsi}, the average growth suppression index.
#'
#' @export
plot_outbreak <- function(x, disp_index = "mean_ngsi"){
  if(!is.outbreak(x)) stop("'x' must be an 'outbreak' object")
  if(! (disp_index == "mean_gsi" | disp_index == "mean_ngsi")) {
    # warning("Displaying the 'mean_ngsi'")
    disp_index <- "mean_ngsi"
  }
  if(disp_index == "mean_ngsi") y_intercept <- 0
  else y_intercept <- 1
  outbrk_events <- x[! is.na(x$outbreak_status), ]
  # setup plot
  p <- ggplot2::ggplot(data = x, ggplot2::aes_string(x="year"))
  # extract minor axes
  foo <- p + ggplot2::geom_line(ggplot2::aes_string(y=disp_index))
  minor_labs <- ggplot2::ggplot_build(foo)$layout$panel_params[[1]]$x.minor_source
  # top plot
  index <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_hline(yintercept = y_intercept, colour = "grey80") +
    ggplot2::geom_line(ggplot2::aes_string(y=disp_index)) +
    ggplot2::geom_segment(data = outbrk_events,
                          ggplot2::aes_string(x="year", xend="year",
                                              y=y_intercept, yend=disp_index),
                          size=2) +
    ggplot2::scale_y_continuous(name = "Growth suppression index") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"),
                   axis.title.x=ggplot2::element_blank(),
                   axis.text.x=ggplot2::element_blank(),
                   axis.ticks.x=ggplot2::element_blank())
  # mid plot
  prop <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_ribbon(ggplot2::aes_string(ymax="perc_defol", ymin=0)) +
    ggplot2::scale_y_continuous(name = "% defoliated") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"),
                   axis.title.x=ggplot2::element_blank(),
                   axis.text.x=ggplot2::element_blank(),
                   axis.ticks.x=ggplot2::element_blank())
  # bottom plot
  line <- p +
    ggplot2::geom_vline(xintercept = minor_labs, colour="grey50") +
    ggplot2::geom_line(ggplot2::aes_string(y="samp_depth")) +
    ggplot2::scale_y_continuous(name = "Sample depth") +
    ggplot2::scale_x_continuous(name = "Year") +
    ggpubr::theme_pubr() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.1, 0, 0, 0), "cm"))
  # combine
  ggpubr::ggarrange(index, prop, line, nrow=3, align = "v")
}

#' Plot a \code{defol} object
#'
#' @param ... arguments passed to \code{plot_defol}
#'
#' @export
plot.defol <- function(...){
  print(plot_defol(...))
}
