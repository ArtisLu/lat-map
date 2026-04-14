# Latvia Area Scoring Explorer

`Latvia Area Scoring Explorer` is a portfolio-ready R Shiny prototype for comparing places in Latvia with a weighted scoring model.

The first version focuses on two distance-based metrics:

- Hospital closeness
- McDonald's closeness

The app converts each distance into a normalized proximity score, applies user-defined weights, and visualizes the result on an interactive map and ranking table.

## Why this is a strong Appsilon-style portfolio piece

This project is intentionally shaped around several skills Appsilon highlights for R/Shiny developers:

- Building attractive, interactive Shiny apps
- Organizing code into reusable helpers instead of one giant `app.R`
- Writing testable business logic
- Using Git-friendly project structure
- Preparing a prototype that can later grow into a more production-ready app

Appsilon's article also points junior candidates toward `Advanced R`, `Mastering Shiny`, `Engineering Production-Grade Shiny Apps`, and practice with `shiny.semantic` / `shiny.fluent`.

## Project structure

- [app.R](C:/Users/MF/Documents/New%20project/app.R)
- [R/app_data.R](C:/Users/MF/Documents/New%20project/R/app_data.R)
- [R/scoring.R](C:/Users/MF/Documents/New%20project/R/scoring.R)
- [R/app_ui.R](C:/Users/MF/Documents/New%20project/R/app_ui.R)
- [R/app_server.R](C:/Users/MF/Documents/New%20project/R/app_server.R)
- [data/latvia_demo_areas.csv](C:/Users/MF/Documents/New%20project/data/latvia_demo_areas.csv)
- [tests/testthat/test-scoring.R](C:/Users/MF/Documents/New%20project/tests/testthat/test-scoring.R)

## Run the app

If `Rscript` is not on your PATH, you can use the full Windows path:

```powershell
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" scripts/install_packages.R
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" -e "shiny::runApp('.', launch.browser = TRUE)"
```

## Run tests

```powershell
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" tests/testthat.R
```

## Current data status

The dataset in [data/latvia_demo_areas.csv](C:/Users/MF/Documents/New%20project/data/latvia_demo_areas.csv) is demo data for prototyping the scoring workflow and UI. It is good enough for building the app structure, but it should be replaced with real, sourced distance data before you present it as a real geographic decision tool.

## Good next upgrades

1. Replace point data with municipality polygons using `sf`.
2. Generate real nearest-distance metrics from OpenStreetMap or another geographic source.
3. Add more scoring dimensions, such as schools, groceries, train access, or EV charging.
4. Add snapshot and unit tests for reactive outputs.
5. Add CI with GitHub Actions and deployment on Posit Connect or shinyapps.io.
6. Rebuild the UI once with `shiny.fluent` or `shiny.semantic` to show Appsilon-adjacent experience.

## Suggested learning roadmap for the Appsilon goal

1. Finish and polish this app until it feels like a genuine portfolio piece.
2. Study `Advanced R` to get stronger with functions, environments, and debugging.
3. Work through `Mastering Shiny` and then `Engineering Production-Grade Shiny Apps`.
4. Learn Git beyond the basics: branching, rebasing, pull requests, and code review habits.
5. Add automated tests and CI to this repo.
6. Build one second app with a different flavor, such as a clinical dashboard, explainable ML app, or multi-page business tool.
