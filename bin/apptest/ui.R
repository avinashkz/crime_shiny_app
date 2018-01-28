#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(tidyverse)
library(shinycssloaders)
library(DT)

options(spinner.color="#008d4b")

dashboardPage(skin="green",
  
              
  dashboardHeader(title = " Visualizing Violent Crimes in US", titleWidth = 300),
  dashboardSidebar(
    sidebarMenu(
    menuItem("Dashboard", tabName = "Dashboard", icon = icon("line-chart"),
             
             sliderInput("slider", h3("Filter year", id = "myh3"),
                         min = 1975, max = 2015, value = c(1975, 2015), sep = ""),
             radioButtons("radio", h3("Radio buttons"),
                          choices = list("Total Population" = "total_pop", "Total Crimes" = "violent_crime","Rape" = "rape_sum",
                                         "Assault" = "agg_ass_sum", "Homicide" = "homs_sum", "Robbery" = "rob_sum"),selected = "violent_crime"),
             
             uiOutput("cities"),
             
             checkboxGroupInput("checkGroup", 
                                h3("Extra Options"), 
                                choices = c("View Crime Proportions" = 1, 
                                            "Remove Trace" = 2, 
                                            "Display Legend" = 3, 
                                            "Enlarge Labels" = 4),
                                selected = c(3))
    ),
            
    menuItem("Data", icon = icon("table"), tabName = "Data",
             
             uiOutput("yearOutput")
             
             
)
    
),
    width = 300
  ),

  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "theme.css")),
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    #https://stackoverflow.com/questions/24652658/suppress-warning-message-in-r-console-of-shiny
    fluidRow(
      tabBox(
        tabPanel(
        title = "Graphs",
    plotlyOutput("geoPlot"),
    
    withSpinner(plotlyOutput("linePlot2", height="340")),
    verbatimTextOutput("selection"),
    
    dataTableOutput("mytable")
        ),
     width = 100,
    
    tabPanel(
      title = "Data"
    
    
      
      
      )
    
    
    
    )
    
    
    
    
    
    )
  )
)


