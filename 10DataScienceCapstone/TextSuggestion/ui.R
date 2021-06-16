#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
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
        titlePanel("A Predictive Text Suggestion Demo"),    
        tabsetPanel(
            id = "mainTabsPanel",
            tabPanel(
                id = "suggestionTab", title = "Suggestion",
                
                # tabPanel(title = "suggestionTab",),
                # Sidebar
                sidebarLayout (
                    sidebarPanel(
                        fluidRow(
                            radioButtons(inputId = "radioButton", 
                                         label = "Corpus source", 
                                         choices = c("Default corpus" = "default",
                                                     "Upload a file to build your model" = "user"),
                                         selected = "default"),
                            conditionalPanel(
                                condition = "input.radioButton == 'default'",
                            ),
                            conditionalPanel(
                                condition = "input.radioButton == 'user'",
                                fileInput("file", "Select a English text file (Max. 1Mb)",
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
                        fluidRow(column(3,actionButton(inputId="suggest", 
                                                       label="Suggest", class="btn btn-primary")),
                                 column(3, actionButton(inputId="reset",
                                                        label=" Reset", class="btn btn-primary")),
                                 column(3, actionButton(inputId="write", style="display: none;",
                                                        label="Write", class="btn btn-primary"))
                        )
                    ),
                    mainPanel(
                        fluidRow(
                            tabsetPanel(
                                id = "tabsPanel",
                                tabPanel(title = "Suggestion (Wordcloud)",
                                         wordcloud2Output("wordcloud"),
                                         tags$script(HTML(
                                             "$(document).on('click', '#canvas', function() {",
                                             'word = document.getElementById("wcSpan").innerHTML;',
                                             "Shiny.onInputChange('wordcloud_click', word);",
                                             "});"))),
                                tabPanel(title = "Suggestion (Barchart)",
                                         plotlyOutput("barchart")),
                                tabPanel(title = "Fun (Composition)", 
                                         helpText("Note: this is not a true composition," ,
                                                  "but it provides an interesting way to apply",
                                                  "our preditive model by generating English-like sentenses.",
                                                  p(),
                                                  "Please type at least one word, it will generate a composition",
                                                  " with around 100 words. It takes a few time to process."
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
                id = "infoTab", title = "About"
            )
        )
    )
)

shinyAppDir(appDir = getwd())




