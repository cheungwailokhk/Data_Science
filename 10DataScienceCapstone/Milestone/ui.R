#   Author: cwl
#   Date: 03/06/2021
#   Data  from World Bank
#
require(shiny);require(tidyr); require(dplyr); require(plotly); require(colorspace)

source("./Auxillary.R")

# Define UI for application that draws a line chart
shinyUI(fluidPage(
    # Application title
    titlePanel("World's Demographics"),

    sidebarLayout(
        sidebarPanel(
            p("Information is provided by World Bank."),
            selectizeInput("selectRegion", label = "Region", 
                           choices = NULL, multiple = TRUE,
                           options = list(placeholder = 'select a region(s)')),
            selectizeInput("selectCountry", label = "Country", 
                           choices = NULL, multiple = TRUE,
                           options = list(placeholder = 'select a country(s)')),
            checkboxGroupInput("checkGroup", 
                               "Income group(s)", 
                               choices = list(),
                               selected = c()),
            sliderInput("yearRange", "Year", min =0, max = 10, value =c(0,0)),
            fluidRow(column(3,actionButton(inputId="sumbit", label="Submit")),
                      column(3, actionButton(inputId="reset", label=" Reset"))
                     )
        ),
        mainPanel(
            fluidRow(
                tabsetPanel(
                    id = "tabsPanel",
                    tabPanel("Birth rate", plotlyOutput("birthPLot")),
                    tabPanel("Death rate", plotlyOutput("deathPlot"))
                )
            ), fluidRow(
            )
        )
    )
))
