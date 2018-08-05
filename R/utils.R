#' Adjust series for comparison of host and non-host
#' @param input_series data.frame rwl object with the host tree series
#' as first column and non-host chornology as second
#' @return data.frame with 3 added columns, (1) the mean/sd sdjusted non-host chronology,
#' (2) the "corrected" host series after subtraction from the adjusted host chronology,
#' and (3) the "normalized" or scaled corrected host series used to identify defoliation events


adjust_series <- function(input_series){
  nms <- colnames(input_series)
  nam1 <- paste(nms[2], '_rescale', sep='')
  nam2 <- paste(nms[1], '_crct', sep='')
  nam3 <- paste(nms[1], '_norm', sep='')
  h_sd <- stats::sd(inut_series[, 1])
  nh_sd <- stats::sd(inut_series[, 2])
  nh_mean <- mean(inut_series[, 2])
  inut_series[, 3] <- (inut_series[, 2] - nh_mean) * (h_sd / nh_sd)
  inut_series[, 4] <- inut_series[, 1] - inut_series[, 3]
  inut_series[, 5] <- scale(inut_series[, 4])
  names(input_series) <- c(nms, nam1, nam2, nam3)
  return(input_series)
}
