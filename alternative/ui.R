library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(tidyverse)
library(shinycssloaders)
library(DT)
library(shinyjs)

options(spinner.color="#008d4b")

dashboardPage(skin="green",
  
              
  dashboardHeader(title = "Violent Crimes in USA", titleWidth = 300),
  dashboardSidebar(
    sidebarMenu(id="menu",
      #Tab for Dashboard
      menuItem("Dashboard", tabName = "Dashboard", icon = icon("line-chart")),
      
      #Tab for table
      menuItem("Data Table", tabName = "Data", icon = icon("table")),
      
              
                
                
                #Slider for filtering year
               sliderInput("slider", h3("Filter Year", id = "myh3"),
                           min = 1975, max = 2015, value = c(1975, 2015), sep = ""),
               
               # Multiple cities selector for line and scatter plot
               uiOutput("cities"),
               
         
    conditionalPanel("input.menu == 'Dashboard'",
               #Radio buttons for selecting y-axis for line and scatter plot
               radioButtons("radio", h3("Select Feature", id = "myh3"),
                            choices = list( "Total Crimes" = "violent_crime","Total Population" = "total_pop","Rape" = "rape_sum",
                                           "Assault" = "agg_ass_sum", "Homicide" = "homs_sum", "Robbery" = "rob_sum"),selected = "violent_crime"),
               
      
              # Extra options for user.
               checkboxGroupInput("checkGroup", 
                                  h3("Extra Options", id = "myh3"), 
                                  choices = c("Crime Per 100k" = 1, 
                                              "Remove Trace" = 2, 
                                              "Display Legend" = 3, 
                                              "Enlarge Labels" = 4),
                                  selected = c(3))
              
              
              #https://stackoverflow.com/questions/29925585/conditional-panel-in-shiny-dashboard
              
    )
              
     

              ),
                 width = 300
              ),

  dashboardBody(
    
    #Adding custom css file.
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "theme.css")),
    #Suppressing warning messages for shiny
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    tabItems(
      
      #Tab for dashboard
      
      tabItem(
            
              tabName = "Dashboard",
              
              fluidRow(
                
                column(12,plotlyOutput("geoPlot"))
                       
              ),
              withSpinner(plotlyOutput("linePlot2", height="340"))
              ),
      #Tab for table.
      
      tabItem(tabName = "Data",
              dataTableOutput("mytable"))
      
    )
    
    #https://stackoverflow.com/questions/24652658/suppress-warning-message-in-r-console-of-shiny
   
             )

      )


