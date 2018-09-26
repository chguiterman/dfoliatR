library(dplR)

bac <- read.compact('data_raw/BAC2.CRN')
bac_crn <- bac[, 1, drop = FALSE]

devtools::use_data(bac_crn, overwrite = TRUE)
