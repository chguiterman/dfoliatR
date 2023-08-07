#' East Fork Jemez River Douglas-fir
#'
#' Western spruce budworm host series
#'
#' @format An `rwl` object with 37 tree-level series, standardized in ARSTAN.
#'   Dates range from 1776-1987.
#'
#' @source \url{https://doi.org/10.2307/2937153}
"efk_h"

#' Baca ponderosa pine chronology
#'
#' Non-host pair chronology for East Fork Douglas-fir `efk_h`
#'
#' @format An `rwl` chronology object with 1 series, 1612-1987. Standardized in
#'   ARSTAN.
#'
#' @source \url{https://doi.org/10.2307/2937153}
"efk_nh"

#' East Fork defol object
#'
#' Produced by running `defoliate_trees(efk_h, efk_nh, series_end_event = TRUE)`
#'
#' @format A `defol` object with 5142 rows and 5 columns
"efk_defol"

#' East Fork outbreak object
#'
#' Produced by running `outbreak(efk_defol)`
#'
#' @format An `outbreak` object with 221 rows and 9 columns
"efk_obr"

#' Demi John Douglas-fir
#'
#' Western spruce budworm host series
#'
#' @format An `rwl` object with 17 tree-level series, standardized in ARSTAN.
#'   Dates range from 1620-1997.
"dmj_h"

#' Demi John area ponderosa pine
#'
#' Non-host pair to Demi John Douglas-fir `dmj_h`
#'
#' @format An `rwl` object with 1 series, 1675-1997.
"dmj_nh"

#' Demi John dfol object
#'
#' Produced by running `defoliate_trees(dmj_h, dmj_nh, series_end_events=TRUE)`
#'
#' @format A `defol` object with 4267 rows and 5 columns
"dmj_defol"

#' Demi John outbreak object
#'
#'  Produced by running `outbreak(dmj_defol)`
#'
#'  @format An `outbreak` object with 323 rows and 9 columns
"dmj_obr"
