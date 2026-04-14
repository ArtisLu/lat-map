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
