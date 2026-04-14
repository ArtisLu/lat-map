source(file.path("..", "..", "R", "scoring.R"), encoding = "UTF-8")

test_that("normalise_proximity rewards shorter distances", {
  scores <- normalise_proximity(c(10, 20, 30))
  expect_equal(scores, c(1, 0.5, 0))
})

test_that("normalise_proximity handles flat inputs", {
  scores <- normalise_proximity(c(5, 5, 5))
  expect_equal(scores, c(1, 1, 1))
})

test_that("calculate_area_scores returns ranked results", {
  sample_data <- data.frame(
    area_name = c("A", "B", "C"),
    planning_region = c("X", "X", "Y"),
    lat = c(56.9, 56.8, 56.7),
    lng = c(24.1, 24.2, 24.3),
    hospital_km = c(1, 20, 10),
    mcdonald_km = c(50, 10, 20),
    stringsAsFactors = FALSE
  )

  scored <- calculate_area_scores(sample_data, hospital_weight = 0.6, mcdonald_weight = 0.4)

  expect_equal(nrow(scored), 3)
  expect_true(all(diff(scored$overall_score) <= 0))
  expect_equal(scored$rank, c(1, 2, 3))
})

test_that("calculate_area_scores rejects invalid weights", {
  sample_data <- data.frame(
    area_name = "A",
    planning_region = "X",
    lat = 56.9,
    lng = 24.1,
    hospital_km = 1,
    mcdonald_km = 1,
    stringsAsFactors = FALSE
  )

  expect_error(
    calculate_area_scores(sample_data, hospital_weight = 0, mcdonald_weight = 0),
    "At least one weight"
  )
})
