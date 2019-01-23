library(dplR)

bac <- read.compact('inst/extdata/BAC2.CRN')
bac_crn <- bac[, 1, drop = FALSE]

devtools::use_data(bac_crn, overwrite = TRUE)
