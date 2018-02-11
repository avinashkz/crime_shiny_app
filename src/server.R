library(shiny)
library(plotly)
library(tidyverse)
library(shinycssloaders)
library(DT)
library(shinydashboard)
library(shinyjs)


#Loading the dataset without national
crime <- read_csv("processed_data_national.csv")


shinyServer(function(input, output) {
  

  
  #Functino for geo plot
  output$geoPlot <- renderPlotly({
    
    my_colors <- c('#d73027','#fc8d59','#fee08b','#d9ef8b','#91cf60','#1a9850')
    
    if(input$radio == "pop"){
      xtitle = "Population in Millions"
      title = "Population"
      q = "pop"
      color = my_colors[2]
    }
    else if(input$radio == "violent") {
      xtitle = "Violent Crime in Thousands"
      title = "Violent Crimes"
      q = "violent"
      color = my_colors[1]
    }
    else if(input$radio == "rape") {
      xtitle = "Number of Rapes"
      title = "Rape"
      q = "rape"
      color = my_colors[3]
    }
    else if(input$radio == "assault") {
      xtitle = "Assaults in Thousands"
      title = "Assault"
      q = "assault"
      color = my_colors[4]
    }
    else if(input$radio == "homicide") {
      xtitle = "Number of Homicides"
      title = "Homicide"
      q = "homicide"
      color = my_colors[5]
    }
    else if(input$radio == "robbery") {
      xtitle = "Robberies in Thousands"
      title = "Robbery"
      q = "robbery"
      color = my_colors[6]
    }
    
    #Filter the data for plotting the geo map
    geo_data <<- crime %>% filter(year == 2014) %>%  group_by(region, code) %>%
      summarise(pop = sum(total_pop, na.rm = TRUE), rape = sum(rape_sum, na.rm = TRUE), assault = sum(agg_ass_sum, na.rm = TRUE),
                robbery = sum(rob_sum, na.rm = TRUE), homicide = sum(homs_sum, na.rm = TRUE), violent = sum(violent_crime, na.rm = TRUE))
    
    #Creating column for contents to hover
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
    
    #Plot geo plot using shiny
    plot1 <- plot_geo(geo_data, locationmode = 'USA-states') %>%
      add_trace(
        z = ~get(q), text = ~hover, locations = ~code,
        color = ~pop, colors = c(color, "#323232")
      ) %>%
      colorbar(title = xtitle) %>%
      layout(
        title = paste('<br>Interactive', title, 'Map(Click to Filter States)'),
        geo = g
      )
  })
  
  # Function for line and scatter plot
  output$linePlot2 <- renderPlotly({
    
    #Reading in the extra option multiple selector input
    a <- str_detect(paste(input$checkGroup, collapse = ","), "1")
    b <- str_detect(paste(input$checkGroup, collapse = ","), "2")
    c <- str_detect(paste(input$checkGroup, collapse = ","), "3")
    d <- str_detect(paste(input$checkGroup, collapse = ","), "4")
    
    #Setting the font size
    if(d) {f <- list(size = 17)} else {f <- list(size = 14)}
    #Switching between line and markers
    if(b) {m <- 'markers'} else {m <- 'lines+markers'}
    #observe({print(input$radio)})
    
    
    #Switching the y-axis of scatter and line plot
    
    if(!a) {
      
      #To plot total count
      
    if(input$radio == "pop"){
      xtitle = "Population in Millions"
      title = "Population Trend In"
      y = "total_pop"
    }
    else if(input$radio == "violent") {
      xtitle = "Violent Crime in Thousands"
      title = "Violent Crime Trend In"
      y = "violent_crime"
    }
    else if(input$radio == "rape") {
      xtitle = "Number of Rapes"
      title = "Rape Trend In"
      y = "rape_sum"
    }
    else if(input$radio == "assault") {
      xtitle = "Assaults in Thousands"
      title = "Assault Trend In"
      y = "agg_ass_sum"
    }
    else if(input$radio == "homicide") {
      xtitle = "Number of Homicides"
      title = "Homicide Trend In"
      y = "homs_sum"
    }
    else if(input$radio == "robbery") {
      xtitle = "Robberies in Thousands"
      title = "Robbery Trend In"
      y = "rob_sum"
    }
    }
    else
    {
      
      #For plots 100k variables
      
    if(input$radio == "pop"){
      xtitle = "Population in Millions"
      title = "Population trend In"
      y = "total_pop"
    }
    else if(input$radio == "violent") {
      xtitle = "Violent Crimes Per 100k"
      title = "Violent Crime Trend In"
      y = "violent_per_100k"
    }
    else if(input$radio == "rape") {
      xtitle = "Rapes Per 100k"
      title = "Rape Trend In"
      y = "rape_per_100k"
    }
    else if(input$radio == "assault") {
      xtitle = "Assaults Per 100k"
      title = "Assault Trend In"
      y = "agg_ass_per_100k"
    }
    else if(input$radio == "homicide") {
      xtitle = "Homicides  Per 100k"
      title = "Homicide Trend In"
      y = "homs_per_100k"
    }
    else if(input$radio == "robbery") {
      xtitle = "Robberies Per 100k"
      title = "Robbery Trend In"
      y = "rob_per_100k"
    }
    }
    
    #Detect geo click
    geo_click <- event_data("plotly_click")
    
    #Readin the input from city selector
    mycities <- input$cityInput
    
    #observe({(print(mycities))})
    if (length(geo_click) & length(mycities)) {
      
      #observe({print("I am here")})
      #z is still the old value. Need to automate the new value!
      x <<- geo_data %>% filter(get(input$radio) == geo_click$z)
      p <- crime %>% filter(region == x[[1]], year >= input$slider[1], year <= input$slider[2]) %>% filter(city %in% mycities) %>% 
        plot_ly(x = ~year, y = ~get(y), type = 'scatter', 
                mode = m, split = ~city,  text = ~paste("Total Crime In ", city)) %>% 
        layout(title = ~paste("<br>",title, x[[1]]), font = f ,xaxis = list(title = "Years", titlefont = f, tickfont = f),
               yaxis = list(title = xtitle, titlefont = f, titlefont = f),
               legend = list(font = f),showlegend = c)

    # } else if (length(mycities)){
    #   #observe({print("I am here too")})
    #   p <- crime %>% filter(year >= input$slider[1], year <= input$slider[2]) %>% filter(city %in% mycities) %>% 
    #     plot_ly(x = ~year, y = ~get(y), type = 'scatter', 
    #             mode = m, split = ~city,  text = ~paste("Total Crime In ", city)) %>% 
    #     layout(title = ~paste("<br>",title, x[[1]]), font = f ,xaxis = list(title = "Years", titlefont = f, tickfont = f),
    #            yaxis = list(title = xtitle, titlefont = f, titlefont = f),
    #            legend = list(font = f),showlegend = c)
    } else {
      #observe({print("I am here too")})
      plot_data <- crime %>% filter(year >= input$slider[1], year <= input$slider[2])  %>%  group_by(region, year) %>%
        summarise(custom = sum(get(y), na.rm = TRUE))
      plot_data %>% 
        plot_ly(x = ~year, y = ~custom, type = 'scatter', 
                mode = m, split = ~region,  text = ~paste("Total Crime In ", region)) %>% 
        layout(title =  ~paste("<br>",title, "US"), font = f, xaxis = list(title = "Years", titlefont = f, tickfont = f),
               yaxis = list(title = xtitle, titlefont = f, titlefont = f),
               legend = list(font = f),showlegend = c)
    }
  })
  
  #https://stackoverflow.com/questions/36980999/change-plotly-chart-y-variable-based-on-selectinput#
  
  #Function for multiple city selector
  
  output$cities <- renderUI({
    
 
    
    d <- event_data("plotly_click")
    if (length(d)) {
      observe({print(d)})
      observe({print(input$radio)})
      x <- geo_data %>% filter(get(input$radio) == d$z)
      observe({print(x)})
      q <- crime %>% filter(region == x[[1]]) %>%
        group_by(city) %>% summarise() %>% as.list()
      selectInput(
        "cityInput",
        h3("Cities Selected"),
        sort(q$city),
        selected = q$city,
        multiple = TRUE)
    }
  })
  
  #To update data table when filters change
  
  data_func <- reactive({
    
    mycities <- input$cityInput
    #observe({print(mycities)})
    if(length(mycities)) {crime %>% filter(year >= input$slider[1], year <= input$slider[2]) %>% filter(city %in% mycities)}
    else
    {crime %>% filter(year >= input$slider[1], year <= input$slider[2])}
    
  })
  
  #Functino to output the data table
  
  output$mytable <- renderDataTable({
    
    DT::datatable(data = data_func(),
                  extensions = 'Buttons', 
                  options = list(
                    scrollX = TRUE,
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'excel', 'pdf')
    ))
  })
  
  #For rendering the tabs of shiny dashboard
  
  output$menuitem <- renderMenu({
    menuItem("Menu item", icon = icon("calendar"))
  })
  
})

