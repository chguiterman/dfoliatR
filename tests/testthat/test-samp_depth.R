data("dmj_defol")

s_vec <- c(2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3)

test_that("samp_depth() counts trees consistently", {
  test_vec <- sample_depth(dmj_defol)[1:20, 2]
  expect_equal(test_vec, s_vec)
})
