library(dplR)

# Demi John host series
dmj_h <- read.compact('inst/extdata/DMJDFARS.TRE')

usethis::use_data(dmj_h, overwrite = TRUE)

# Nonhost chronology for Eastfork
wir <- read.crn('inst/extdata/Wirpipo.crn')
dmj_nh <- wir[, 1, drop = FALSE]

usethis::use_data(dmj_nh, overwrite = TRUE)
