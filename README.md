# Latvia Area Scoring Explorer

`Latvia Area Scoring Explorer` is an R Shiny portfolio app for comparing places in Latvia with a simple weighted location score.

Users can adjust how important each metric is, then immediately see how the ranking changes on an interactive map and in a ranked results table. The current prototype uses two distance-based dimensions:

- Hospital closeness
- McDonald's closeness

That makes the app easy to understand, but the scoring engine is intentionally written so you can swap in richer real-world metrics later, such as schools, grocery stores, public transport, rail access, or EV charging.

## Why this project exists

This app serves two goals at once:

1. Build a practical geographic scoring tool for Latvia.
2. Create a strong portfolio piece for R/Shiny developer roles such as the ones Appsilon hires for.

It demonstrates several habits that matter in real Shiny work:

- reactive UI design
- reusable scoring logic outside the main app file
- testable helper functions
- a clean project structure
- a path to production improvements like CI, deployment, and real spatial data

## What the app does

- lets users assign a weight split between hospitals and McDonald's
- converts raw distances into normalized proximity scores
- combines those scores into a final 0 to 100 area score
- colors Latvia locations by score on an interactive `leaflet` map
- shows rankings in both a chart and a searchable table
- supports filtering by planning region

## Scoring approach

Each distance metric is transformed into a proximity score where shorter distance is better. The final score is a weighted average of those metric scores:

```text
overall_score = 100 * (hospital_weight * hospital_score + mcdonald_weight * mcdonald_score)
```

The current data file is a prototype dataset used to validate the interaction design and scoring workflow. Before presenting this as a real decision-support tool, the demo values should be replaced with sourced geographic distance data.

## Tech stack

- `shiny`
- `leaflet`
- `DT`
- `testthat`

## Project structure

- [app.R](<C:/Users/MF/Documents/New project/app.R>)
- [R/app_data.R](<C:/Users/MF/Documents/New project/R/app_data.R>)
- [R/scoring.R](<C:/Users/MF/Documents/New project/R/scoring.R>)
- [R/app_ui.R](<C:/Users/MF/Documents/New project/R/app_ui.R>)
- [R/app_server.R](<C:/Users/MF/Documents/New project/R/app_server.R>)
- [data/latvia_demo_areas.csv](<C:/Users/MF/Documents/New project/data/latvia_demo_areas.csv>)
- [tests/testthat/test-scoring.R](<C:/Users/MF/Documents/New project/tests/testthat/test-scoring.R>)

## Run locally

```powershell
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" scripts/install_packages.R
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" -e "shiny::runApp('.', launch.browser = TRUE)"
```

## Run tests

```powershell
& "C:\Program Files\R\R-4.1.1\bin\Rscript.exe" tests/testthat.R
```

## Why this fits an Appsilon-style portfolio

Appsilon's R/Shiny career guidance highlights more than just getting an app to render. It points toward strong R fundamentals, good UI instincts, reusable code, Git fluency, testing, and product thinking. This project is intentionally aligned to that direction.

Relevant reference:

- [How to Start a Career as an R Shiny Developer](https://www.appsilon.com/post/how-to-start-a-career-as-an-r-shiny-developer)

## Good next upgrades

1. Replace point data with municipality polygons using `sf`.
2. Generate real nearest-distance metrics from OpenStreetMap or another geographic data source.
3. Add more scoring dimensions and let users rebalance all of them dynamically.
4. Add snapshot tests and reactive tests.
5. Add GitHub Actions for checks and deployment.
6. Rebuild the UI once with `shiny.fluent`, `shiny.semantic`, or Rhino for broader Appsilon-relevant experience.

## Learning roadmap

1. Polish this app until it feels like a finished portfolio artifact.
2. Study `Advanced R`.
3. Work through `Mastering Shiny`.
4. Study `Engineering Production-Grade Shiny Apps`.
5. Build a second Shiny project in a different domain.
6. Practice Git and pull-request based workflow regularly.
