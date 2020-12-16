context("Plotting")
library(dfoliatR)
library(ggplot2)

## mirror {vdiffr} `expect_doppelganger()`

expect_doppelganger <- function(title, fig, path = NULL, ...) {
  testthat::skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(title, fig, path = path, ...)
}


test_that("output of ggplot() is stable", {
  expect_doppelganger("A blank plot", ggplot())
})

test_that("defol plot is stable", {
  expect_doppelganger("Defol-Gantt-Plot",
              plot_defol(dfoliatR::dmj_defol))
})

test_that("outbreak plot is stable", {
  expect_doppelganger("Outbreak-Tile-Plot",
              plot_outbreak(dfoliatR::dmj_obr))
})
