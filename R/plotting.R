#' Produce a Gantt plot of individual tree-ring series to show defoliation
#' events in time
#'
#' @param x a `defol` object produced by [defoliate_trees()].
#' @param breaks a vector length two providing threshold (negative) `ngsi`
#'   values to separate minor, moderate, and severe defoliation events. If
#'   blank, the mean and 1st quartile are used.
#'
#' @importFrom rlang .data :=
#' @importFrom ggplot2 ggplot aes geom_segment theme_bw theme element_blank
#' scale_colour_manual
#'
#' @examples
#' data("dmj_defol")
#' plot_defol(dmj_defol)
#'
#' ## Change the values severity classes
#' plot_defol(dmj_defol, breaks = c(-1.0, -0.5))
#'
#' @export
plot_defol <- function(x, breaks) {
  stopifnot(is.defol(x))
  s_stats <- defol_stats(x)
  e_stats <- get_defol_events(x)
  if (! missing(breaks)) {
    break_vals <- breaks
  }
  else break_vals <- summary(e_stats$ngsi_mean)[c(2, 4)]
  e_stats$Severity <- cut(e_stats$ngsi_mean,
                          breaks = c(-Inf,
                                     break_vals[[1]],
                                     break_vals[[2]],
                                     Inf),
                          right = FALSE,
                          labels = c("Severe",
                                     "Moderate",
                                     "Minor"))
  p <- ggplot(x, aes(x = .data$year, y = .data$series))
  p <- p + geom_segment(data = s_stats,
                         aes(x = .data$first,
                             xend = .data$last,
                             y = .data$series,
                             yend = .data$series),
                         linetype = "dotted")
  p <- p +
    geom_segment(data = e_stats,
                         aes(x = .data$start_year,
                             xend = .data$end_year,
                             y = .data$series,
                             yend = .data$series,
                             colour = .data$Severity),
                         linetype = "solid",
                         size = 1.25) +
    # custom colors, provided by ggsci::pal_npg()
    scale_colour_manual(values = c( "#DC0000FF", "#F39B7FFF", "#4DBBD5FF"))
  p <- p + theme_bw() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.title = element_blank(),
      legend.position = "bottom"
    )
  p
}


#' Produce a stacked plot to present composited, site-level insect outbreak
#' chronologies
#'
#' @param x an 'obr' object produced by [outbreak()]
#' @param disp_index Identify the timeseries index to plot. Defaults to
#'   `NGSI`, the average normalized growth suppression index for the
#'   site. The only other option is `GSI`, the average growth
#'   suppression index.
#'
#' @importFrom rlang .data
#' @importFrom  magrittr %>%
#' @importFrom ggplot2 ggplot aes geom_segment geom_vline theme_bw theme
#'   element_blank geom_line geom_hline scale_y_continuous scale_x_continuous
#'   geom_ribbon unit
#'
#' @export
plot_outbreak <- function(x, disp_index = c("GSI", "NGSI")) {

  if (!is.obr(x)) stop("'x' must be an 'obr' object")
  if (missing(disp_index)) disp_index <- "NGSI"
  if (! disp_index %in% c("NGSI", "GSI")) {
    stop("Please assign either 'NGSI' or 'GSI' to the `disp_index` argument")
  }

  if (disp_index == "NGSI") {
    y_intercept <- 0
    var <- "mean_ngsi"
  }
  if (disp_index == "GSI") {
    y_intercept <- 1
    var <- "mean_gsi"
  }

  outbrk_events <- x %>%
    dplyr::mutate(!!var := replace(.data[[var]],
                                   .data$outbreak_status == "not_obr",
                                   y_intercept))

  # setup plot
  p <- ggplot(data = x, aes(x = .data$year))
  # extract minor axes
  foo <- p + geom_line(aes(y = .data[[var]]))
  minor_labs <-
    ggplot2::ggplot_build(foo)$layout$panel_params[[1]]$x.sec$minor_breaks
  # top plot
  line <- p +
    geom_vline(xintercept = minor_labs, colour = "grey90") +
    geom_line(aes(y = .data$samp_depth)) +
    scale_y_continuous(name = "# trees") +
    ggpubr::theme_pubr() +
    theme(plot.margin = unit(c(0.1, 0, 0, 0), "cm"),
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank())
  # middle plot
  index <- p +
    geom_vline(xintercept = minor_labs, colour = "grey90") +
    geom_hline(yintercept = y_intercept, colour = "grey80") +
    # geom_area(data=outbrk_events, aes(x = .data$year,
    #                                   y = .data[[var]]),
    #           stat = "identity") +
    geom_ribbon(data = outbrk_events, aes(x = .data$year,
                                        ymin = .data[[var]],
                                        ymax = y_intercept)) +
    geom_line(aes(y = .data[[var]])) +
    scale_y_continuous(name = disp_index) +
    ggpubr::theme_pubr() +
    theme(plot.margin = unit(c(0.1, 0, 0, 0), "cm"),
                   axis.title.x = element_blank(),
                   axis.text.x = element_blank(),
                   axis.ticks.x = element_blank())
  # bottom plot
  prop <- p +
    geom_vline(xintercept = minor_labs, colour = "grey90") +
    geom_ribbon(aes(ymax = .data$perc_defol, ymin = 0)) +
    scale_y_continuous(name = "% defoliated") +
    scale_x_continuous(name = "Year") +
    ggpubr::theme_pubr() +
    theme(plot.margin = unit(c(0.1, 0, 0, 0), "cm"))

  # combine
  ggpubr::ggarrange(line, index, prop,
                    nrow = 3,
                    align = "v",
                    heights = c(1, 2, 2))
}

#' Plot a `defol` object
#'
#' @param ... arguments passed to [plot_defol()]
#'
#' @export
plot.defol <- function(...) {
  print(plot_defol(...))
}
