library(dplR)

# East fork host series
ef_h <- read.compact('inst/extdata/EFKDF2.TRE')

usethis::use_data(ef_h, overwrite = TRUE)

# Nonhost chronology for Eastfork
bac <- read.compact('inst/extdata/BAC2.CRN')
ef_nh <- bac[, 1, drop = FALSE]

usethis::use_data(ef_nh, overwrite = TRUE)
