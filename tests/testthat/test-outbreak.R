context("Outbreak")
library(dfoliatR)

data("efk_obr")

test_obr <- outbreak(efk_defol)

obr_stats <- outbreak_stats(test_obr)

test_that("outbreak consistently defines outbreaks", {
  expect_equal(efk_obr$outbreak_status, test_obr$outbreak_status)
})

test_that("outbreak_stats gets the same first interval", {
  expect_equivalent(data.frame(1788, 1796), obr_stats[1, 1:2])
})

test_that("outbreak stats finds the same number of events", {
  expect_equal(nrow(obr_stats), 10)
})
