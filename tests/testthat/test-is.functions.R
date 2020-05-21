data("dmj_nh")
data("dmj_h")

test_defol <- defoliate_trees(dmj_h, dmj_nh)
test_obr <- outbreak(test_defol)

test_that("defol objects are classed correctly", {
  expect_true(is.defol(test_defol))
})

test_that("non-defol objects are caught", {
  expect_false(is.defol(dmj_h))
})

test_that("obr objects are classed correctly", {
  expect_true(is.obr(test_obr))
})

test_that("non-obr objects are caught", {
  expect_false(is.obr(test_defol))
})
