context("Plotting")
library(dfoliatR)
library(ggplot2)

test_that("output of ggplot() is stable", {
  vdiffr::expect_doppelganger("A blank plot", ggplot())
})

test_that("defol plot is stable", {
  vdiffr::expect_doppelganger("Defol-Gantt-Plot",
              plot_defol(dfoliatR::dmj_defol))
})

test_that("outbreak plot is stable", {
  vdiffr::expect_doppelganger("Outbreak-Tile-Plot",
              plot_outbreak(dfoliatR::dmj_obr))
})

