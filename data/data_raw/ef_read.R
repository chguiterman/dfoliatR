library(dplR)

ef <- read.compact('data_raw/EFKDF2.TRE')

devtools::use_data(ef, overwrite = TRUE)
