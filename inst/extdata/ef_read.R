library(dplR)

ef <- read.compact('inst/extdata/EFKDF2.TRE')

devtools::use_data(ef, overwrite = TRUE)
