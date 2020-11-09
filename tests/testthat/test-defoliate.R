context("Defoliate trees")
library(dfoliatR)

data("efk_defol")

test_defol <- defoliate_trees(host_tree = dfoliatR::efk_h,
                              nonhost_chron = dfoliatR::efk_nh,
                              series_end_event = TRUE)


test_that("gsi calculates the growth stress index consistently", {
  expect_equal(test_defol$gsi, efk_defol$gsi)
})

test_that("id_defoliation runs consistently", {
  expect_equal(test_defol$defol_status, efk_defol$defol_status)
})

test_that("defoliate_trees() runs in host-only mode", {
  host_only_defol <- defoliate_trees(host_tree = dfoliatR::dmj_h)
  expect_equal(as.vector(host_only_defol[1:11, "defol_status"]),
               c("nd", "nd", "nd", "nd", "nd", "nd", "nd", "defol",
                 "max_defol", "defol", "defol"))
})
