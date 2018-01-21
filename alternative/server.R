
#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(tidyverse)
library(shinycssloaders)
library(DT)
library(shinydashboard)
library(shinyjs)


crime <- read_csv("../results/processed_data_national.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$geoPlot <- renderPlotly({
    
    geo_data <<- crime %>% filter(year == 2014) %>%  group_by(region, code) %>%
      summarise(pop = sum(total_pop, na.rm = TRUE), rape = sum(rape_sum, na.rm = TRUE), assault = sum(agg_ass_sum, na.rm = TRUE),
                robbery = sum(rob_sum, na.rm = TRUE), homicide = sum(homs_sum, na.rm = TRUE), violent = sum(violent_crime, na.rm = TRUE))
    
    geo_data$hover <- with(geo_data, paste(region, '<br>',
                                 "Rape: ",rape, '<br>',"Assault: ", assault,'<br>',
                                 "Robbery: ", robbery, '<br>',"Homicide: ", homicide))
    
    # give state boundaries a white border
    l <- list(color = toRGB("white"), width = 2)
    
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
    
    plot1 <- plot_geo(geo_data, locationmode = 'USA-states') %>%
      add_trace(
        z = ~violent, text = ~hover, locations = ~code,
        color = ~pop, colors = c("#008d4b", "darkgrey", "#323232")
      ) %>%
      colorbar(title = "Crime in Thousands") %>%
      layout(
        title = '<br>Interactive Violent Crimes Map (2014)',
        geo = g
      )
  })
  
  
  output$linePlot2 <- renderPlotly({
    
    a <- str_detect(paste(input$checkGroup, collapse = ","), "1")
    b <- str_detect(paste(input$checkGroup, collapse = ","), "2")
    c <- str_detect(paste(input$checkGroup, collapse = ","), "3")
    d <- str_detect(paste(input$checkGroup, collapse = ","), "4")
    
    if(d) {f <- list(size = 16)} else {f <- list(size = 14)}
    if(b) {m <- 'markers'} else {m <- 'lines+markers'}
    #observe({print(input$radio)})
    
    if(!a) {
    if(input$radio == "total_pop"){
      xtitle = "Population in Millions"
      title = "Population trend In"
      y = "total_pop"
    }
    else if(input$radio == "violent_crime") {
      xtitle = "Violent Crime in Thousands"
      title = "Violent Crime trend In"
      y = "violent_crime"
    }
    else if(input$radio == "rape_sum") {
      xtitle = "Number of Rapes"
      title = "Rape trend In"
      y = "rape_sum"
    }
    else if(input$radio == "agg_ass_sum") {
      xtitle = "Assaults in Thousands"
      title = "Assault trend In"
      y = "agg_ass_sum"
    }
    else if(input$radio == "homs_sum") {
      xtitle = "Number of Homicides"
      title = "Homicide trend In"
      y = "homs_sum"
    }
    else if(input$radio == "rob_sum") {
      xtitle = "Robberies in Thousands"
      title = "Robbery trend In"
      y = "rob_sum"
    }
    }
    else
    {
    if(input$radio == "total_pop"){
      xtitle = "Population in Millions"
      title = "Population trend In"
      y = "total_pop"
    }
    else if(input$radio == "violent_crime") {
      xtitle = "Violent Crime Per 100k"
      title = "Violent Crime trend In"
      y = "violent_per_100k"
    }
    else if(input$radio == "rape_sum") {
      xtitle = "Rapes Per 100k"
      title = "Rape trend In"
      y = "rape_per_100k"
    }
    else if(input$radio == "agg_ass_sum") {
      xtitle = "Assaults Per 100k"
      title = "Assault trend In"
      y = "agg_ass_per_100k"
    }
    else if(input$radio == "homs_sum") {
      xtitle = "Homicides  Per 100k"
      title = "Homicide trend In"
      y = "homs_per_100k"
    }
    else if(input$radio == "rob_sum") {
      xtitle = "Robberies Per 100k"
      title = "Robbery trend In"
      y = "rob_per_100k"
    }
    }
    
    geo_click <- event_data("plotly_click")
    mycities <- input$cityInput
    
    #observe({(print(mycities))})
    if (length(geo_click) & length(mycities)) {
      
      #observe({print("I am here")})
      x <<- geo_data %>% filter(violent == geo_click$z)
      p <- crime %>% filter(region == x[[1]], year >= input$slider[1], year <= input$slider[2]) %>% filter(city %in% mycities) %>% 
        plot_ly(x = ~year, y = ~get(y), type = 'scatter', 
                mode = m, split = ~city,  text = ~paste("Total Crime In ", city)) %>% 
        layout(title = ~paste(title, x[[1]]) ,xaxis = list(title = "Years", titlefont = f, tickfont = f),
               yaxis = list(title = xtitle, titlefont = f, titlefont = f),
               legend = list(font = f),showlegend = c)

    } else {
      #observe({print("I am here too")})
      plot_data <- crime %>% filter(year >= input$slider[1], year <= input$slider[2])  %>%  group_by(region, year) %>%
        summarise(custom = sum(get(y), na.rm = TRUE))
      plot_data %>% 
        plot_ly(x = ~year, y = ~custom, type = 'scatter', 
                mode = m, split = ~region,  text = ~paste("Total Crime In ", region)) %>% 
        layout(title =  ~paste(title, "US") ,xaxis = list(title = "Years", titlefont = f, tickfont = f),
               yaxis = list(title = xtitle, titlefont = f, titlefont = f),
               legend = list(font = f),showlegend = c)
    }
  })
  
  #https://stackoverflow.com/questions/36980999/change-plotly-chart-y-variable-based-on-selectinput#
  
  output$cities <- renderUI({
    
    d <- event_data("plotly_click")
    if (length(d)) {
      #observe({print(d)})
      x <- geo_data %>% filter(violent == d$z)
      q <- crime %>% filter(region == x[[1]]) %>%
        group_by(city) %>% summarise() %>% as.list()
      selectInput(
        "cityInput",
        h3("Select Cities"),
        sort(q$city),
        selected = q$city,
        multiple = TRUE)
    } else {
      selectInput(
        "cityInput",
        h3("Select Cities"),
        sort(unique(crime$city)),
        multiple = TRUE)
    }
  })
  

  data_func <- reactive({
    
    mycities <- input$cityInput
    #observe({print(mycities)})
    if(length(mycities)) {crime %>% filter(year >= input$slider[1], year <= input$slider[2]) %>% filter(city %in% mycities)}
    else
    {crime %>% filter(year >= input$slider[1], year <= input$slider[2])}
    
  })
  
  output$mytable <- renderDataTable({
    
    DT::datatable(data = data_func(),
                  extensions = 'Buttons', 
                  options = list(
                    scrollX = TRUE,
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'excel', 'pdf')
    ))
  })
  
  output$menuitem <- renderMenu({
    menuItem("Menu item", icon = icon("calendar"))
  })
  
})

