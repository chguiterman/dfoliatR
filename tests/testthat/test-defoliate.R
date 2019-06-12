context('Defoliate trees')
library(dfoliatR)

data("ef_defol")

test_defol <- defoliate_trees(host_tree = dfoliatR::ef_h,
                              nonhost_chron = dfoliatR::ef_nh,
                              series_end_event = TRUE)

test_that("gsi calculates the growth stress index consistently", {
  # expect_equal(x_gsi$EFK01_gsi, check_dat$gsi)
  expect_equal(test_defol$gsi, ef_defol$gsi)
})

test_that("id_defoliation runs consistently", {
  expect_equal(test_defol$defol_status, ef_defol$defol_status)
})


