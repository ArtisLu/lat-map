load_latvia_demo_data <- function(path = file.path("data", "latvia_demo_areas.csv")) {
  if (!file.exists(path)) {
    stop("Could not find the demo data file: ", path, call. = FALSE)
  }

  read.csv(
    path,
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8"
  )
}
