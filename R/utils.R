#' Correct host series
#' @description Removes the nonhost growth signal (ie. climate) from host series
#'
#' @param input_series data.frame rwl object with the host tree series
#' as first column and non-host chornology as second
#'
#' @return data.frame with 3 added columns, (1) the mean/sd sdjusted non-host chronology,
#' (2) the "corrected" host series after subtraction from the adjusted host chronology,
#' and (3) the "normalized" or scaled climate-corrected host series used to identify defoliation events


correct_host_series <- function(input_series){
  nms <- colnames(input_series)
  nam1 <- paste(nms[2], '_rescale', sep='')
  nam2 <- paste(nms[1], '_crct', sep='')
  nam3 <- paste(nms[1], '_norm', sep='')
  h_sd <- stats::sd(input_series[, 1])
  nh_sd <- stats::sd(input_series[, 2])
  nh_mean <- mean(input_series[, 2])
  input_series[, 3] <- (input_series[, 2] - nh_mean) * (h_sd / nh_sd)
  input_series[, 4] <- input_series[, 1] - input_series[, 3]
  input_series[, 5] <- scale(input_series[, 4])
  names(input_series) <- c(nms, nam1, nam2, nam3)
  return(input_series)
}

#' Identify defoliation events in climate-corrected host series
#' @param input_series a data.frame with 5 columns. This was generated after running
#' \code{remove_climate}.
#'
#' @param duration_years the minimum length of time in which the tree is considered to be in defoliation
#'
#' @param max_reduction defaults to -1.28
#'
#' @return after performing runs analyses, the function adds a column to the input data.frame
#' that distinguished years of defoliation and the maximum defoliation year (ie. the year the
#' greatest negative growth departure).

id_defoliation <- function(input_series, duration_years = 8, max_reduction = -1.28){
  rns <- rle(as.vector(input_series[, 5] < 0))
  rns.index = cumsum(rns$lengths)
  neg.runs.pos <- which(rns$values == TRUE)
  ends <- rns.index[neg.runs.pos]
  newindex = ifelse(neg.runs.pos > 1, neg.runs.pos - 1, 0)
  starts <- rns.index[newindex] + 1
  if (0 %in% newindex) starts = c(1,starts)
  deps <- data.frame(cbind(starts, ends))
  deps$length <- deps$ends - deps$starts + 1
  for(y in 1:nrow(deps)){
    bb <- input_series[deps$starts[y] : deps$ends[y], 5]
    max.red <- deps$starts[y] + which.min(bb) - 1
    if(input_series[max.red, 5] > max_reduction) next  # Includes setting for max growth reduction
    dep.seq <- deps$starts[y] : deps$ends[y]
    if(y > 1){
      if(min(dep.seq) - deps$ends[y - 1] == 2) dep.seq <- c(deps$starts[y - 1] : max(dep.seq))
    }
    if(y < nrow(deps)){
      if(deps$starts[y + 1] - max(dep.seq) == 2) dep.seq <- c(min(dep.seq) : deps$ends[y + 1])
    }
    if(length(dep.seq) < duration_years) next # Includes setting for min defoliation duration
    if(min(input_series[dep.seq, 5]) != input_series[max.red, 5]) next
    input_series[dep.seq, 6] <- "defoliated"
    input_series[max.red, 6] <- "max_defoliation"
  }
  names(input_series)[6] <- "defol_status"
  return(input_series)
}


#' stack defolation list object
#'

stack_defoliation <- function(x){
  out <- ldply(x, function(i){
    inout <- range(as.numeric(rownames(i)))
    yrs <- as.integer(c(inout[1], as.numeric(rownames(i))[!is.na(i$rec_type)], inout[2]))
    out <- data.frame(year = yrs, series = colnames(i)[1], defol_status = i[, 6])
    return(out)
  }
  )
  class(out) <- c('defol_tree', 'data.frame')
  return(out)
}


