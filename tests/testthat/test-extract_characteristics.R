test_that("extract_characteristics extracts characteristics", {

  x <- c(
    "cell type: HeLa",
    "treatment: control",
    "time: 24 hours"
  )

  result <- extract_characteristics(x)

  expect_equal(result$cell.type, "HeLa")
  expect_equal(result$treatment, "control")
  expect_equal(result$time, "24 hours")

})
