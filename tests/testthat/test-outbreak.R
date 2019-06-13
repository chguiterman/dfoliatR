context("Outbreak")
library(dfoliatR)

data("ef_obr")

test_obr <- outbreak(dfoliatR::ef_defol)

obr_stats <- outbreak_stats(test_obr)

test_that("outbreak consistently defines outbreaks",{
  expect_equal(ef_obr$outbreak_status, test_obr$outbreak_status)
})

test_that("outbreak_stats gets the same first interval",{
  expect_equivalent(data.frame(1790, 1808), obr_stats[1, 1:2])
})

test_that("outbreak stats finds the same number of events",{
  expect_equal(nrow(obr_stats), 9)
})

