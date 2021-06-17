#   Author: cwl
#   Date: 15/06/2021
#   GitHub: https://github.com/cwl286/datasciencecoursera/tree/master/10DataScienceCapstone/TextSuggestion
#
#   This source is for the Shiny UI
# 
#   This source requires ui.R, server.R, utils.R, and dataframe objects to run.
#   NgramsBuilders.R build the dataframe objects (./data/N2gram.rds, ./data/N3gram.rds, 
#   ./data/N5gram.rds, ./data/N7gram.rds)
#
#

require(shiny); require(shinyjs)
require(plotly);require(wordcloud2); require(dplyr)

# UI for a shiny application
ui <- shinyUI(
    fluidPage(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "./css/style.css")
        ),
        useShinyjs(), # Set up shinyjs
        # Application title
        titlePanel("Predictive Text Suggestion"),    
        tabsetPanel( id = "mainTabsPanel",
            tabPanel( id = "suggestionTab", title = "Suggestion",
                # tabPanel(title = "suggestionTab",),
                # Sidebar
                sidebarLayout (
                    sidebarPanel(
                        fluidRow(
                            radioButtons(inputId = "radioButton", 
                                         label = "Corpus source", 
                                         choices = c("Default" = "default",
                                                     "Upload a file to build your model" = "user"),
                                         selected = "default"),
                            conditionalPanel(
                                condition = "input.radioButton == 'default'",
                            ),
                            conditionalPanel(
                                condition = "input.radioButton == 'user'",
                                fileInput("file", "Select an English text file (Max. 1Mb)",
                                          accept = "txt"),
                                actionButton(inputId="process", style="display: none;",
                                             label="Process your corpus", class="btn btn-primary")
                            ),
                            textAreaInput(inputId = "text", 
                                          label = "As you type text, you see predictions for your next word.",
                                          rows = 7),
                            numericInput(inputId = "numericInput",
                                         label = "Maximum number of suggestion",
                                         value = 40, min = 5, max = 100
                            ),
                            checkboxInput(inputId = "checkbox", 
                                          label =" Auto-Suggestion", 
                                          value = TRUE)
                        ),
                        fluidRow(
                            column(3,actionButton(inputId="suggest", 
                                                  label="Suggest", class="btn btn-primary")),
                            column(3, actionButton(inputId="reset",
                                                   label=" Reset", class="btn btn-primary")),
                            column(3, actionButton(inputId="write", style="display: none;",
                                                   label="Write", class="btn btn-primary"))
                        ),
                        br(),
                        HTML('<p><em>Report a <a href="https://github.com/cwl286/datasciencecoursera/issues" target="_blank" rel="noopener">bug</a> or view the ',
                          '<a href="https://github.com/cwl286/datasciencecoursera/tree/master/10DataScienceCapstone/TextSuggestion" target="_blank" rel="noopener">source</a>.</em></p>')
                    ),
                    mainPanel(
                        fluidRow(
                            tabsetPanel(
                                id = "tabsPanel",
                                tabPanel(title = "Suggestion in Wordcloud",
                                         wordcloud2Output("wordcloud"),
                                         tags$script(HTML(
                                             "$(document).on('click', '#canvas', function() {",
                                             'word = document.getElementById("wcSpan").innerHTML;',
                                             "Shiny.onInputChange('wordcloud_click', word);",
                                             "});"))),
                                tabPanel(title = "Suggestion in Barchart",
                                         plotlyOutput("barchart")),
                                tabPanel(title = "For Fun", 
                                         helpText(
"Note: this is not a proper composition, but it can provide a fun way to apply the",
"selected predictive model. Please type at least one word then our model will generate",
"an English-like composition with around 100 words if possible. It can take a little time to process."
                                         ),
                                         textOutput("composition"),
                                         ),
                                tabPanel(title = "More Model Examples", 
                                         fluidRow(column(4,tableOutput("model2")),
                                                  column(4,tableOutput("model3")),
                                                  column(5,tableOutput("model5")),
                                                  column(7,tableOutput("model7"))
                                                  )
                                         )
                            )
                        )
                    )
                )
            ), 
            tabPanel(
                id = "aboutTab", title = "About",
                includeHTML("./data/html/about.html")
            ),
            tabPanel(
                id = "bkgTab", title = "Background",
                includeHTML("./data/html/background.html")
            )
        )
    )
)

shinyAppDir(appDir = getwd())




