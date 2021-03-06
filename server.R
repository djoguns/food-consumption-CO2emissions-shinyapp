server <- server <- function(input, output, session) {
  output$datatable <- DT::renderDataTable({
    if (input$countries == 'All Countries') {
      output <- final_table
    } else {
      output <- filter(final_table, country %in% input$countries)
    }
    DT::datatable(output,
                  filter = "top",
                  options = list(scrollX = TRUE))
  })
  
  filtered_map <- reactive({
    req(input$food)
    filtered_map <- subset(map2, food_category == input$food)
    filtered_map$labels <- paste0(
      "<strong> Country: </strong> ",
      filtered_map$country,
      "<br/> ",
      "<strong> Food type consumption in kg/per capita: </strong> ",
      filtered_map$consumption,
      "<br/> ",
      "<strong> Co2 emissions in ton/per capita: </strong> ",
      filtered_map$co2_emmission,
      "<br/> "
    ) %>%
      lapply(htmltools::HTML)
    
    filtered_map
  })
  
  
  data_to_map <- reactive({
    req(input$map_var)
    
    switch(
      input$map_var,
      "CO2 emissions" = filtered_map()$co2_emmission,
      "Food Consumption" = filtered_map()$consumption
    )
  })
  
  
  output$map <- renderLeaflet({
    req(input$food)
    req(input$map_var)
    
    pal <- colorBin(palette = "viridis",
                    domain = data_to_map(),
                    bins = 7)
    
    leaflet(filtered_map()) %>%
      addTiles() %>%
      setView(lng = 0,
              lat = 30,
              zoom = 2) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~ pal(data_to_map()),
        color = "white",
        fillOpacity = 0.7,
        label = ~ labels,
        highlight = highlightOptions(color = "black",
                                     bringToFront = TRUE)
      ) %>%
      leaflet::addLegend(
        position = "bottomleft",
        pal = pal,
        values = ~ data_to_map(),
        opacity = 0.7,
        title = paste0(input$map_var)
      )
  })
}
