# Demi John host series
dmj_h <- dplR::read.compact('inst/extdata/DMJDFARS.TRE')

usethis::use_data(dmj_h, overwrite = TRUE)

# Nonhost chronology for Demi John
wir <- dplR::read.crn('inst/extdata/Wirpipo.crn')
dmj_nh <- wir[, 1, drop = FALSE]

usethis::use_data(dmj_nh, overwrite = TRUE)

# Run defoliate_trees

dmj_defol <- dfoliatR::defoliate_trees(dmj_h, dmj_nh, series_end_event = TRUE)

usethis::use_data(dmj_defol, overwrite = TRUE)

# Run outbreak on defol
dmj_obr <- dfoliatR::outbreak(dmj_defol)

usethis::use_data(dmj_obr, overwrite = TRUE)
