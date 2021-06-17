#   Author: cwl
#   Date: 15/06/2021
#   GitHub: https://github.com/cwl286/datasciencecoursera/tree/master/10DataScienceCapstone/TextSuggestion
#
#   This source is for the Shiny server
#
#   This source requires ui.R, server.R, utils.R, and dataframe objects to run.
#   NgramsBuilders.R build the dataframe objects (./data/N2gram.rds, ./data/N3gram.rds, 
#   ./data/N5gram.rds, ./data/N7gram.rds)
#
#

require(shiny); require(shinyjs)
require(plotly);require(wordcloud2); require(dplyr)
require(tm); require(SnowballC); require(stopwords); 
require(tokenizers);  require(tidyr); require(dplyr);  

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
    #initalize tools
    source("./utils.R")
    v <- reactiveValues(N2gram = NA, N3gram = NA, N5gram = NA, N7gram = NA, # default Ngram
                        suggestion_df  = NA, reset = FALSE, 
                        source = "default", # "default" or "user"
                        isUserNgramBuilt = FALSE, input_path = NA,
                        userN2gram = NA, userN3gram = NA, userN5gram = NA, userN7gram = NA)
    
    # Initialize values
    observe({
        #initalize data
        # Load default Ngram for utils
        v$N2gram <- readRDS("./data/N2gram.rds")
        v$N3gram <- readRDS("./data/N3gram.rds")
        v$N5gram <- readRDS("./data/N5gram.rds")
        v$N7gram <- readRDS("./data/N7gram.rds")
        v$suggestion_df <- v$N7gram # initial suggestion
    })
    
    # Plot barchart
    output$barchart <- renderPlotly({
        plotyBarchart(df = v$suggestion_df, topN = input$numericInput, chartTitle = 'Most frequent terms')
    })
    
    # Plot wordcloud
    output$wordcloud <- renderWordcloud2({
        plotWordCloud(df = v$suggestion_df, topN = input$numericInput, size = 1)
    })
    
    
    # Set to use default or user's Ngrams for word suggestion
    suggestWordByStatus <- function(text) {
        if (v$source == "user" && v$isUserNgramBuilt) {
            suggestWord(v$userN2gram, v$userN3gram, v$userN5gram, v$userN7gram, text)
        } else {
            suggestWord(v$N2gram, v$N3gram, v$N5gram, v$N7gram, text)
        }
    }
    
    # Monitor radioButton to choose default or user corpus
    observeEvent(input$radioButton, {
        if (input$radioButton == "user") {
            v$source = "user"
            if (v$isUserNgramBuilt) {
                v$suggestion_df <- v$userN2gram
            } else {
                v$suggestion_df <- v$N5gram
            }
        } else {
            v$source = "default"
            v$suggestion_df <- v$N5gram
        }
    })
    
    # Monitor file upload under radioButton
    observeEvent(input$file, {
        v$input_path <- input$file$datapath
        ext <- tools::file_ext(v$input_path)
        
        if (ext != "txt"){
            alert("Please upload a txt file")
            return()
        } else if(file.info(v$input_path)$size > 1000000) {
            alert("Please upload a txt file less than 1 Mb")
            return()
        }
        shinyjs::show("process")
    })
    
    # User upload process button after a user uploaded a file
    observeEvent(input$process, {
        shinyjs::disable("process") # Avoid repeatedly clicking
        # Preprocessing
        runjs("document.getElementById('process').innerHTML = 'Preprocessing Corpus")
        
        inputCorpus <- VCorpus(VectorSource(loadData(urls = c(v$input_path), samplePercent = 1)))
        inputCorpus <- cleanCorpus(inputCorpus, removeStopwords = FALSE,
                                  isStemming = FALSE,
                                  isLemmatization = FALSE)
        
        # Building Ngrams by user's corpus
        runjs("document.getElementById('process').innerHTML = 'Building Ngrams'")
        
        # Split N-gram into two parts: first n-1 words and last word
        v$userN2gram <- convertTdmToDf(createNgram(inputCorpus, n = 2, lowfreq = 1)) %>%
            separate(word,c("firstPart","lastPart"),sep=" (?=[^ ]*$)")
        v$userN3gram <- convertTdmToDf(createNgram(inputCorpus, n = 3, lowfreq = 1)) %>%
            separate(word,c("firstPart","lastPart"),sep=" (?=[^ ]*$)")
        v$userN5gram <- convertTdmToDf(createNgram(inputCorpus, n = 5, lowfreq = 1)) %>%
            separate(word,c("firstPart","lastPart"),sep=" (?=[^ ]*$)")
        v$userN7gram <- convertTdmToDf(createNgram(inputCorpus, n = 7, lowfreq = 1)) %>%
            separate(word,c("firstPart","lastPart"),sep=" (?=[^ ]*$)")
        # Update status
        v$isUserNgramBuilt = TRUE
        v$source = "user"
        v$suggestion_df <- v$userN2gram
        runjs("document.getElementById('process').innerHTML = 'Using your model'")
    })
    
    # Reset button
    observeEvent(input$reset, {
        updateTextInput(session, inputId = "text",value = "")
        updateNumericInput(session, inputId = "numericInput", value = 40)
        # v$suggestion_df <- v$N3gram # delay to observeEvent(text) 
        v$reset = TRUE
        output$composition <- renderText({""})
        shinyjs::hide("process")
        shinyjs::enable("process")
        updateActionButton(inputId = "process", label = "Process your corpus")
        v$isUserNgramBuilt = FALSE
        v$source = "default"
    })
    
    # Submit button Event
    observeEvent(input$suggest, {
        if (!is.na(input$text) & trimws(input$text) != "") {
            # Check empty text input
            v$suggestion_df <- suggestWordByStatus(input$text)
        }
    })
    
    # Monitor write button
    observeEvent(input$write, {
        if (!is.na(input$text) & trimws(input$text) != "") {
            start = trimws(input$text)
            for (i in 1:100) {
                words <- suggestWordByStatus(start)
                if (nrow(words) == 0) {
                    break
                }
                # sample one word from top 5 sugggestion
                suggestion <- head(words, 5)$lastPart 
                start <- paste(start, sample(suggestion, 1))
            }
            output$composition <- renderText({
                start
            })
        }
    })

    # Monitor the change in the tag panel
    observeEvent(input$tabsPanel, {
        if (input$tabsPanel == "For Fun") {
            shinyjs::show("write")
        } else {
            shinyjs::hide("write")
        } 
        
        if (input$tabsPanel == "More Model Examples") {
            if (input$radioButton == "user" && v$isUserNgramBuilt) {
                output$model2 <- renderTable({sample_n(v$userN2gram, 20)})
                output$model3 <- renderTable({sample_n(v$userN3gram, 20)})
                output$model5 <- renderTable({sample_n(v$userN5gram, 20)})
                output$model7 <- renderTable({sample_n(v$userN7gram, 20)})
            } else {
                output$model2 <- renderTable({sample_n(v$N2gram, 20)})
                output$model3 <- renderTable({sample_n(v$N3gram, 20)})
                output$model5 <- renderTable({sample_n(v$N5gram, 20)})
                output$model7 <- renderTable({sample_n(v$N7gram, 20)})
            }
        }
    })
    
    # Monitor text input box  (also the auto suggestion checkbox)
    observeEvent(input$text,  {
        if (v$reset) {
            # Result now since reset was delayed
            v$suggestion_df <- v$N5gram
            v$reset <- FALSE
        }
        # if auto-suggestion is ticked, auto update the text input box
        if (input$checkbox) {
            if (!is.na(input$text) & trimws(input$text) != "") {
                v$suggestion_df <- suggestWordByStatus(input$text)
            }
        }
    })
    
    # Monitor when a user click a word in the wordcloud
    observeEvent(input$wordcloud_click, {
        words <- sapply( strsplit(input$wordcloud_click, ":"), head, 1)
        if (!is.na(input$text) & trimws(input$text) != "") {
            lastWord <- sapply(strsplit(words, " "), tail, 1)
            updateTextInput(session, "text",
                            value = paste(trimws(input$text), lastWord, sep = " "))
        } else {
            updateTextInput(session, "text", value = words)
        }
    })

    # Monitor when a user click a word in the barchart
    observeEvent(event_data("plotly_click"), {
        words <- event_data("plotly_click")$y
        if (!is.na(input$text) & trimws(input$text) != "") {
            lastWord <- sapply(strsplit(words, " "), tail, 1)
            updateTextInput(session, "text",
                            value = paste(trimws(input$text), lastWord, sep = " "))
        } else {
            updateTextInput(session, "text", value = words)
        }
    })
})