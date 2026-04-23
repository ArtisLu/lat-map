load_latvia_boundary <- function(path = file.path("data", "latvia_boundary.geojson")) {
  if (!file.exists(path)) {
    stop("Could not find the Latvia boundary file: ", path, call. = FALSE)
  }

  boundary <- sf::read_sf(path, quiet = TRUE)
  sf::st_transform(boundary, 4326)
}

filter_surface_to_boundary <- function(surface_grid, boundary) {
  required_columns <- c(
    "lat_min",
    "lat_max",
    "lng_min",
    "lng_max",
    "lat_center",
    "lng_center",
    "surface_score"
  )
  missing_columns <- setdiff(required_columns, names(surface_grid))

  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  if (!inherits(boundary, "sf")) {
    stop("Boundary must be an sf object.", call. = FALSE)
  }

  center_points <- sf::st_as_sf(
    surface_grid,
    coords = c("lng_center", "lat_center"),
    crs = sf::st_crs(boundary)
  )
  boundary_geometry <- sf::st_make_valid(boundary["geometry"])
  inside_idx <- lengths(sf::st_within(center_points, boundary_geometry)) > 0
  filtered_surface <- surface_grid[inside_idx, , drop = FALSE]

  filtered_surface$popup_label <- sprintf(
    "Interpolated score: %.1f",
    filtered_surface$surface_score
  )

  filtered_surface
}
