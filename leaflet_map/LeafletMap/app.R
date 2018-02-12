#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         leafletOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  crime <- read_csv("../coord.csv")
  
  pal <- colorNumeric("viridis", NULL)
   
   output$distPlot <- renderLeaflet({
     
     nycounties <- geojsonio::geojson_read("counties.geojson",
                                           what = "sp")
     # Or use the rgdal equivalent:
     # nycounties <- rgdal::readOGR("counties.geojson", "OGRGeoJSON")
     
     states <- geojsonio::geojson_read("counties.geojson", what = "sp")
     class(states)
     
     names(states)
     pal <- colorNumeric("viridis", NULL)
     
     bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
     pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
     
     m <- leaflet(states) %>%
       setView(-96, 37.8, 4) %>%
       addProviderTiles("MapBox", options = providerTileOptions(
         id = "mapbox.light",
         accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))
     
     m %>% addPolygons(
       fillColor = ~pal(CENSUSAREA),
       weight = 2,
       opacity = 1,
       color = "white",
       dashArray = "3",
       fillOpacity = 0.7,
       highlight = highlightOptions(
         weight = 5,
         color = "#666",
         dashArray = "",
         fillOpacity = 0.7,
         bringToFront = TRUE))
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

