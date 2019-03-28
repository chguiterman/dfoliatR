library(dplR)
library(dfoliatR)

# Demi John host series
dmj_h <- read.compact('inst/extdata/DMJDFARS.TRE')

usethis::use_data(dmj_h, overwrite = TRUE)

# Nonhost chronology for Demi John
wir <- read.crn('inst/extdata/Wirpipo.crn')
dmj_nh <- wir[, 1, drop = FALSE]

usethis::use_data(dmj_nh, overwrite = TRUE)

# Run defoliate_trees
dmj_defol <- defoliate_trees(dmj_h, dmj_nh, series_end_event = TRUE)

usethis::use_data(dmj_defol, overwrite = TRUE)

# Run outbreak on defol
dmj_obr <- outbreak(dmj_defol)

usethis::use_data(dmj_obr, overwrite = TRUE)
