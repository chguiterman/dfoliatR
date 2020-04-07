# East fork host series
efk_h <- dplR::read.compact("inst/extdata/EFKARS.TRE")

usethis::use_data(efk_h, overwrite = TRUE)

# Nonhost chronology for Eastfork
efk_nh <- dplR::read.crn("inst/extdata/BAC2.CRN")

usethis::use_data(efk_nh, overwrite = TRUE)

# Run defoliate_trees
efk_defol <- dfoliatR::defoliate_trees(efk_h, efk_nh, series_end_event = TRUE)

usethis::use_data(efk_defol, overwrite = TRUE)

# Run outbreak on defol
efk_obr <- dfoliatR::outbreak(efk_defol)

usethis::use_data(efk_obr, overwrite = TRUE)
