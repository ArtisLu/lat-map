build_app_server <- function() {
  function(input, output, session) {
    raw_data <- load_latvia_demo_data()

    shiny::observe({
      shiny::updateSelectInput(
        session = session,
        inputId = "planning_region",
        choices = c("All Latvia", sort(unique(raw_data$planning_region))),
        selected = "All Latvia"
      )
    })

    output$mcdonald_weight_text <- shiny::renderUI({
      shiny::div(
        class = "weights-chip",
        sprintf(
          "McDonald's closeness weight is currently %s%%.",
          100 - input$hospital_weight
        )
      )
    })

    filtered_data <- shiny::reactive({
      data <- raw_data

      if (!is.null(input$planning_region) && !identical(input$planning_region, "All Latvia")) {
        data <- data[data$planning_region == input$planning_region, , drop = FALSE]
      }

      data
    })

    scored_data <- shiny::reactive({
      calculate_area_scores(
        data = filtered_data(),
        hospital_weight = input$hospital_weight / 100,
        mcdonald_weight = (100 - input$hospital_weight) / 100
      )
    })

    output$best_area_card <- shiny::renderUI({
      scored <- scored_data()
      best_area <- scored$area_name[1]
      best_score <- sprintf("%.1f / 100", scored$overall_score[1])

      build_value_card(
        title = "Top scoring area",
        value = paste(best_area, best_score, sep = "\n"),
        tone = "teal"
      )
    })

    output$score_span_card <- shiny::renderUI({
      scored <- scored_data()
      score_span <- sprintf(
        "%.1f to %.1f",
        min(scored$overall_score),
        max(scored$overall_score)
      )

      build_value_card(
        title = "Visible score range",
        value = score_span,
        tone = "gold"
      )
    })

    output$weight_split_card <- shiny::renderUI({
      build_value_card(
        title = "Weight split",
        value = sprintf(
          "%s%% hospitals\n%s%% McDonald's",
          input$hospital_weight,
          100 - input$hospital_weight
        ),
        tone = "green"
      )
    })

    output$score_map <- leaflet::renderLeaflet({
      scored <- scored_data()
      palette <- leaflet::colorNumeric(
        palette = c("#b11226", "#f3c623", "#1a8f5f"),
        domain = scored$overall_score
      )

      labels <- sprintf(
        paste(
          "<strong>%s</strong><br/>",
          "Region: %s<br/>",
          "Hospital distance: %.0f km<br/>",
          "McDonald's distance: %.0f km<br/>",
          "Score: %.1f"
        ),
        scored$area_name,
        scored$planning_region,
        scored$hospital_km,
        scored$mcdonald_km,
        scored$overall_score
      )

      label_text <- if (isTRUE(input$show_labels)) scored$area_name else NULL

      leaflet::leaflet(scored) |>
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) |>
        leaflet::addCircleMarkers(
          lng = ~lng,
          lat = ~lat,
          radius = ~6 + (overall_score / 18),
          stroke = TRUE,
          weight = 1,
          color = "#ffffff",
          opacity = 1,
          fillOpacity = 0.9,
          fillColor = ~palette(overall_score),
          popup = labels,
          label = label_text
        ) |>
        leaflet::addLegend(
          position = "bottomright",
          pal = palette,
          values = ~overall_score,
          title = "Score"
        )
    })

    output$ranking_plot <- shiny::renderPlot({
      scored <- scored_data()
      top_n <- min(input$top_n, nrow(scored))
      top_scores <- scored[seq_len(top_n), ]

      bar_colors <- colorRampPalette(c("#12343b", "#2d6a4f", "#95d5b2"))(top_n)
      old_par <- par(no.readonly = TRUE)
      on.exit(par(old_par), add = TRUE)

      par(mar = c(5, 10, 3, 2))
      barplot(
        rev(top_scores$overall_score),
        names.arg = rev(top_scores$area_name),
        horiz = TRUE,
        col = rev(bar_colors),
        las = 1,
        xlim = c(0, 100),
        xlab = "Score",
        main = "Highest scoring areas under the selected weights"
      )
    })

    output$ranking_table <- DT::renderDT({
      scored <- scored_data()
      display_table <- scored[
        ,
        c(
          "rank",
          "area_name",
          "planning_region",
          "hospital_km",
          "mcdonald_km",
          "overall_score"
        )
      ]
      names(display_table) <- c(
        "Rank",
        "Area",
        "Planning region",
        "Hospital distance (km)",
        "McDonald's distance (km)",
        "Overall score"
      )

      DT::datatable(
        display_table,
        rownames = FALSE,
        options = list(
          pageLength = 10,
          autoWidth = TRUE,
          dom = "tip"
        )
      )
    })
  }
}
