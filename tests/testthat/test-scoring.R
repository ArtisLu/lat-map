source(file.path("..", "..", "R", "scoring.R"), encoding = "UTF-8")
source(file.path("..", "..", "R", "spatial.R"), encoding = "UTF-8")

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

test_that("generate_score_surface produces a full interpolation grid", {
  scored_data <- data.frame(
    area_name = c("A", "B"),
    planning_region = c("X", "Y"),
    lat = c(56.9, 57.2),
    lng = c(24.1, 25.3),
    overall_score = c(25, 75),
    stringsAsFactors = FALSE
  )

  surface <- generate_score_surface(scored_data, lat_cells = 4, lng_cells = 5)

  expect_equal(nrow(surface), 20)
  expect_true(all(c("lat_min", "lat_max", "lng_min", "lng_max", "surface_score") %in% names(surface)))
  expect_true(all(surface$surface_score >= min(scored_data$overall_score)))
  expect_true(all(surface$surface_score <= max(scored_data$overall_score)))
})

test_that("generate_score_surface preserves a single-point score everywhere", {
  scored_data <- data.frame(
    area_name = "Only point",
    planning_region = "X",
    lat = 56.95,
    lng = 24.11,
    overall_score = 63,
    stringsAsFactors = FALSE
  )

  surface <- generate_score_surface(scored_data, lat_cells = 3, lng_cells = 3)

  expect_true(all(surface$surface_score == 63))
})

test_that("filter_surface_to_boundary keeps only cells inside the boundary", {
  surface_grid <- data.frame(
    lat_min = c(0, 0),
    lat_max = c(1, 1),
    lng_min = c(0, 1),
    lng_max = c(1, 2),
    lat_center = c(0.5, 0.5),
    lng_center = c(0.5, 1.5),
    surface_score = c(20, 80)
  )

  boundary <- sf::st_sf(
    name = "test",
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(0, 0, 1.5, 0, 1.5, 1, 0, 1, 0, 0),
        ncol = 2,
        byrow = TRUE
      ))),
      crs = 4326
    )
  )

  filtered <- filter_surface_to_boundary(surface_grid, boundary)

  expect_equal(nrow(filtered), 1)
  expect_equal(filtered$surface_score, 20)
  expect_true("popup_label" %in% names(filtered))
})
