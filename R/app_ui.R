build_value_card <- function(title, value, tone = "teal") {
  shiny::div(
    class = paste("value-card", paste0("tone-", tone)),
    shiny::div(class = "value-card-title", title),
    shiny::div(class = "value-card-value", value)
  )
}

build_app_ui <- function() {
  shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(
        shiny::HTML(
          "
          body {
            background: linear-gradient(180deg, #f4f7fb 0%, #eef4f0 100%);
            color: #1f2933;
            font-family: 'Segoe UI', Tahoma, sans-serif;
          }
          .app-shell {
            max-width: 1280px;
            margin: 0 auto;
          }
          .hero {
            background: linear-gradient(135deg, #12343b 0%, #2d6a4f 100%);
            border-radius: 18px;
            color: #ffffff;
            margin: 18px 0 22px 0;
            padding: 24px 28px;
            box-shadow: 0 20px 45px rgba(18, 52, 59, 0.18);
          }
          .hero h1 {
            font-size: 30px;
            font-weight: 700;
            margin: 0 0 8px 0;
          }
          .hero p {
            font-size: 15px;
            line-height: 1.6;
            margin: 0;
            max-width: 900px;
          }
          .panel-soft {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(18, 52, 59, 0.08);
            border-radius: 18px;
            box-shadow: 0 12px 30px rgba(31, 41, 51, 0.08);
            margin-bottom: 18px;
            padding: 18px;
          }
          .sidebar-title,
          .section-title {
            color: #12343b;
            font-size: 17px;
            font-weight: 700;
            margin: 0 0 12px 0;
          }
          .weights-chip {
            background: #eef7f1;
            border-left: 4px solid #2d6a4f;
            border-radius: 12px;
            color: #12343b;
            font-size: 14px;
            margin-bottom: 14px;
            padding: 12px 14px;
          }
          .value-card {
            border-radius: 18px;
            color: #ffffff;
            margin-bottom: 15px;
            min-height: 110px;
            padding: 18px;
            box-shadow: 0 14px 24px rgba(31, 41, 51, 0.14);
          }
          .value-card-title {
            font-size: 13px;
            letter-spacing: 0.04em;
            opacity: 0.9;
            text-transform: uppercase;
          }
          .value-card-value {
            font-size: 26px;
            font-weight: 700;
            line-height: 1.2;
            margin-top: 10px;
            white-space: pre-line;
          }
          .tone-teal {
            background: linear-gradient(135deg, #12343b 0%, #1f5d66 100%);
          }
          .tone-gold {
            background: linear-gradient(135deg, #a16207 0%, #f59e0b 100%);
          }
          .tone-green {
            background: linear-gradient(135deg, #1b4332 0%, #40916c 100%);
          }
          .explain-box {
            background: #f7fbf8;
            border-radius: 14px;
            padding: 16px;
          }
          .formula {
            background: #12343b;
            border-radius: 12px;
            color: #ffffff;
            font-family: Consolas, monospace;
            font-size: 14px;
            margin: 12px 0;
            padding: 12px 14px;
          }
          .legend-note {
            color: #52606d;
            font-size: 13px;
            margin-top: 10px;
          }
          "
        )
      )
    ),
    shiny::div(
      class = "app-shell",
      shiny::div(
        class = "hero",
        shiny::h1("Latvia Area Scoring Explorer"),
        shiny::p(
          paste(
            "Prototype an area scoring tool for Latvia by weighting how close each location is",
            "to essential services and amenities. This demo uses hospitals and McDonald's as the",
            "first two metrics, and it is structured so you can replace the demo values with real",
            "distance data later."
          )
        )
      ),
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          width = 4,
          shiny::div(
            class = "panel-soft",
            shiny::div(class = "sidebar-title", "Score Controls"),
            shiny::sliderInput(
              inputId = "hospital_weight",
              label = "Hospital closeness weight (%)",
              min = 0,
              max = 100,
              value = 60,
              step = 5
            ),
            shiny::uiOutput("mcdonald_weight_text"),
            shiny::selectInput(
              inputId = "planning_region",
              label = "Planning region",
              choices = "All Latvia",
              selected = "All Latvia"
            ),
            shiny::sliderInput(
              inputId = "top_n",
              label = "Areas to highlight in ranking chart",
              min = 3,
              max = 10,
              value = 5,
              step = 1
            ),
            shiny::checkboxInput(
              inputId = "show_labels",
              label = "Show area labels on the map",
              value = TRUE
            )
          ),
          shiny::div(
            class = "panel-soft",
            shiny::div(class = "sidebar-title", "About This Prototype"),
            shiny::tags$p(
              "This project combines spatial thinking, reactive controls, and a transparent scoring",
              "formula so you can experiment with how place-based weights affect results across Latvia."
            ),
            shiny::tags$p(
              "The current version uses demo service-distance inputs, but the same structure can be",
              "extended with richer real-world geographic data."
            )
          )
        ),
        shiny::mainPanel(
          width = 8,
          shiny::fluidRow(
            shiny::column(4, shiny::uiOutput("best_area_card")),
            shiny::column(4, shiny::uiOutput("score_span_card")),
            shiny::column(4, shiny::uiOutput("weight_split_card"))
          ),
          shiny::tabsetPanel(
            id = "main_tabs",
            shiny::tabPanel(
              "Map",
              shiny::div(
                class = "panel-soft",
                shiny::div(class = "section-title", "Interactive score map"),
                leaflet::leafletOutput("score_map", height = "560px"),
                shiny::div(
                  class = "legend-note",
                  "The shaded surface is interpolated from the scored locations and clipped to the Latvia boundary."
                )
              )
            ),
            shiny::tabPanel(
              "Rankings",
              shiny::div(
                class = "panel-soft",
                shiny::div(class = "section-title", "Top scoring areas"),
                shiny::plotOutput("ranking_plot", height = "280px")
              ),
              shiny::div(
                class = "panel-soft",
                shiny::div(class = "section-title", "Detailed score table"),
                DT::DTOutput("ranking_table")
              )
            ),
            shiny::tabPanel(
              "How It Works",
              shiny::div(
                class = "panel-soft explain-box",
                shiny::div(class = "section-title", "Scoring logic"),
                shiny::tags$p(
                  "Each distance metric is converted into a 0 to 1 proximity score, where shorter",
                  "distance means a higher value. The final score is the weighted average of those",
                  "metric scores, multiplied by 100."
                ),
                shiny::div(
                  class = "formula",
                  "overall_score = 100 * (hospital_weight * hospital_score + mcdonald_weight * mcdonald_score)"
                ),
                shiny::tags$p(
                  "For a production version, replace the demo CSV with real municipality or parish-level",
                  "data and join the scores to Latvia polygons with the sf package."
                ),
                shiny::tags$p(
                  "Good next metrics could include schools, rail access, grocery stores, EV charging,",
                  "or public service coverage."
                )
              )
            )
          )
        )
      )
    )
  )
}
