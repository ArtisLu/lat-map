required_packages <- c("shiny", "leaflet", "DT")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Install required packages before running the app: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

for (file in list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)) {
  source(file, encoding = "UTF-8")
}

shiny::shinyApp(
  ui = build_app_ui(),
  server = build_app_server()
)
