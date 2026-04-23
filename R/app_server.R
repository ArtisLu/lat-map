build_app_server <- function() {
  function(input, output, session) {
    raw_data <- load_latvia_demo_data()
    latvia_boundary <- load_latvia_boundary()

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
      selected_region <- input$planning_region

      if (is.null(selected_region) || length(selected_region) == 0 || identical(selected_region, "")) {
        selected_region <- "All Latvia"
      }

      if (!identical(selected_region, "All Latvia")) {
        data <- data[data$planning_region == selected_region, , drop = FALSE]
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

    surface_data <- shiny::reactive({
      generate_score_surface(scored_data(), lat_cells = 20, lng_cells = 26)
    })

    masked_surface <- shiny::reactive({
      filter_surface_to_boundary(surface_data(), latvia_boundary)
    })

    output$best_area_card <- shiny::renderUI({
      scored <- scored_data()
      shiny::req(nrow(scored) > 0)
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
      shiny::req(nrow(scored) > 0)
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
      surface <- masked_surface()
      shiny::req(nrow(scored) > 0, nrow(surface) > 0)
      palette <- leaflet::colorNumeric(
        palette = c("#b11226", "#f3c623", "#1a8f5f"),
        domain = c(0, 100)
      )
      boundary_bbox <- sf::st_bbox(latvia_boundary)

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

      leaflet::leaflet() |>
        leaflet::fitBounds(
          lng1 = unname(boundary_bbox["xmin"]),
          lat1 = unname(boundary_bbox["ymin"]),
          lng2 = unname(boundary_bbox["xmax"]),
          lat2 = unname(boundary_bbox["ymax"])
        ) |>
        leaflet::addRectangles(
          data = surface,
          lng1 = ~lng_min,
          lat1 = ~lat_min,
          lng2 = ~lng_max,
          lat2 = ~lat_max,
          stroke = FALSE,
          fillOpacity = 0.6,
          fillColor = ~palette(surface_score),
          popup = ~popup_label
        ) |>
        leaflet::addPolygons(
          data = latvia_boundary,
          fill = FALSE,
          color = "#12343b",
          weight = 2,
          opacity = 0.9
        ) |>
        leaflet::addCircleMarkers(
          data = scored,
          lng = ~lng,
          lat = ~lat,
          radius = ~4 + (overall_score / 25),
          stroke = TRUE,
          weight = 1,
          color = "#ffffff",
          opacity = 1,
          fillOpacity = 1,
          fillColor = ~palette(overall_score),
          popup = labels,
          label = label_text
        ) |>
        leaflet::addLegend(
          position = "bottomright",
          pal = palette,
          values = c(0, 100),
          title = "Surface score"
        )
    })

    output$ranking_plot <- shiny::renderPlot({
      scored <- scored_data()
      shiny::req(nrow(scored) > 0)
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
      shiny::req(nrow(scored) > 0)
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
