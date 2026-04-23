validate_score_inputs <- function(data, hospital_weight, mcdonald_weight) {
  required_columns <- c(
    "area_name",
    "planning_region",
    "lat",
    "lng",
    "hospital_km",
    "mcdonald_km"
  )

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  if (!is.numeric(hospital_weight) || !is.numeric(mcdonald_weight)) {
    stop("Weights must be numeric.", call. = FALSE)
  }

  if (hospital_weight < 0 || mcdonald_weight < 0) {
    stop("Weights cannot be negative.", call. = FALSE)
  }

  if ((hospital_weight + mcdonald_weight) <= 0) {
    stop("At least one weight must be greater than zero.", call. = FALSE)
  }

  invisible(TRUE)
}

normalise_proximity <- function(x) {
  range_x <- range(x, na.rm = TRUE)
  spread <- diff(range_x)

  if (is.na(spread) || spread == 0) {
    return(rep(1, length(x)))
  }

  1 - ((x - range_x[1]) / spread)
}

calculate_area_scores <- function(data, hospital_weight = 0.6, mcdonald_weight = 0.4) {
  validate_score_inputs(data, hospital_weight, mcdonald_weight)

  weights <- c(hospital = hospital_weight, mcdonald = mcdonald_weight)
  weights <- weights / sum(weights)

  scored <- data
  scored$hospital_score <- normalise_proximity(scored$hospital_km)
  scored$mcdonald_score <- normalise_proximity(scored$mcdonald_km)
  scored$overall_score <- round(
    100 * (
      (weights["hospital"] * scored$hospital_score) +
        (weights["mcdonald"] * scored$mcdonald_score)
    ),
    1
  )
  scored$rank <- rank(-scored$overall_score, ties.method = "first")

  scored[order(scored$rank), ]
}

generate_score_surface <- function(
  scored_data,
  lat_cells = 35,
  lng_cells = 45,
  power = 2,
  padding_factor = 0.12,
  min_padding = 0.15
) {
  required_columns <- c("lat", "lng", "overall_score")
  missing_columns <- setdiff(required_columns, names(scored_data))

  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  if (nrow(scored_data) == 0) {
    stop("Surface generation requires at least one scored area.", call. = FALSE)
  }

  if (nrow(scored_data) == 1) {
    lat_breaks <- seq(
      from = scored_data$lat[1] - min_padding,
      to = scored_data$lat[1] + min_padding,
      length.out = lat_cells + 1
    )
    lng_breaks <- seq(
      from = scored_data$lng[1] - min_padding,
      to = scored_data$lng[1] + min_padding,
      length.out = lng_cells + 1
    )

    grid <- expand.grid(
      lat_index = seq_len(lat_cells),
      lng_index = seq_len(lng_cells)
    )

    grid$lat_min <- lat_breaks[grid$lat_index]
    grid$lat_max <- lat_breaks[grid$lat_index + 1]
    grid$lng_min <- lng_breaks[grid$lng_index]
    grid$lng_max <- lng_breaks[grid$lng_index + 1]
    grid$lat_center <- (grid$lat_min + grid$lat_max) / 2
    grid$lng_center <- (grid$lng_min + grid$lng_max) / 2
    grid$surface_score <- scored_data$overall_score[1]

    return(grid)
  }

  lat_range <- range(scored_data$lat, na.rm = TRUE)
  lng_range <- range(scored_data$lng, na.rm = TRUE)

  lat_padding <- max(diff(lat_range) * padding_factor, min_padding)
  lng_padding <- max(diff(lng_range) * padding_factor, min_padding)

  lat_breaks <- seq(
    from = lat_range[1] - lat_padding,
    to = lat_range[2] + lat_padding,
    length.out = lat_cells + 1
  )
  lng_breaks <- seq(
    from = lng_range[1] - lng_padding,
    to = lng_range[2] + lng_padding,
    length.out = lng_cells + 1
  )

  grid <- expand.grid(
    lat_index = seq_len(lat_cells),
    lng_index = seq_len(lng_cells)
  )

  grid$lat_min <- lat_breaks[grid$lat_index]
  grid$lat_max <- lat_breaks[grid$lat_index + 1]
  grid$lng_min <- lng_breaks[grid$lng_index]
  grid$lng_max <- lng_breaks[grid$lng_index + 1]
  grid$lat_center <- (grid$lat_min + grid$lat_max) / 2
  grid$lng_center <- (grid$lng_min + grid$lng_max) / 2

  idw_score <- function(target_lat, target_lng) {
    lat_distance <- scored_data$lat - target_lat
    lng_distance <- (scored_data$lng - target_lng) * cos(target_lat * pi / 180)
    distance <- sqrt((lat_distance ^ 2) + (lng_distance ^ 2))

    if (any(distance < 1e-8)) {
      return(scored_data$overall_score[which.min(distance)])
    }

    weights <- 1 / (distance ^ power)
    sum(weights * scored_data$overall_score) / sum(weights)
  }

  grid$surface_score <- vapply(
    seq_len(nrow(grid)),
    function(i) idw_score(grid$lat_center[i], grid$lng_center[i]),
    numeric(1)
  )

  grid
}
