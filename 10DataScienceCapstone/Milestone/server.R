#   Author: cwl
#   Date: 03/06/2021
#   Data (03/06/2021) from the World Bank 
#

require(shiny);require(tidyr); require(dplyr); require(plotly); require(colorspace)


url_birth_data <- "./data/birth/API_SP.DYN.CBRT.IN_DS2_en_csv_v2_2445306.csv"
url_birth_meta <-"./data/birth/Metadata_Country_API_SP.DYN.CBRT.IN_DS2_en_csv_v2_2445306.csv"

url_death_data <- "./data/death/API_SP.DYN.CDRT.IN_DS2_en_csv_v2_2445773.csv"
url_death_meta <-"./data/death/Metadata_Country_API_SP.DYN.CDRT.IN_DS2_en_csv_v2_2445773.csv"

url_fertility_data <- "./data/fertility/API_SP.DYN.TFRT.IN_DS2_en_csv_v2_2449143.csv"
url_fertility_meta <-"./data/fertility/Metadata_Country_API_SP.DYN.TFRT.IN_DS2_en_csv_v2_2449143.csv"

url_life_data <- "./data/lifeExpectancy/API_SP.DYN.LE00.IN_DS2_en_csv_v2_2445326.csv"
url_life_meta <-"./data/lifeExpectancy/Metadata_Country_API_SP.DYN.LE00.IN_DS2_en_csv_v2_2445326.csv"

url_life_m_data <- "./data/lifeExpectancy_m/API_SP.DYN.LE00.MA.IN_DS2_en_csv_v2_2449295.csv"
url_life_m_meta <-"./data/lifeExpectancy_m/Metadata_Country_API_SP.DYN.LE00.MA.IN_DS2_en_csv_v2_2449295.csv"

url_life_f_data <- "./data/lifeExpectancy_f/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2_2449921.csv"
url_life_f_meta <-"./data/lifeExpectancy_f/Metadata_Country_API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2_2449921.csv"


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    #initalize data
    birthRate <- loadData(url_birth_data, url_birth_meta)
    deathRate <- loadData(url_death_data, url_death_meta)
    fertilityRate <- loadData(url_fertility_data, url_fertility_meta)
    lifeRate <- loadData(url_life_data, url_life_meta)
    lifeRate_m <- loadData(url_life_m_data, url_life_m_meta)
    lifeRate_f <- loadData(url_life_f_data, url_life_f_meta)
    
    v <- reactiveValues(data = NULL)
    v$df <- birthRate@df
    v$df_meta <- birthRate@metadata
    
    v$country_codes <- c()
    v$country_names <- c()
    
    # Monitor the slider values
    observeEvent(input$yearRange, {
        v$yearMin <- input$yearRange[1]
        v$yearMax <- input$yearRange[2]
    })
    # Submit button
    observeEvent(input$sumbit, {
        df <- v$df
        df_meta <- v$df_meta
        if (!is.null(input$selectCountry)) {
            v$country_codes <- df[df$Country.Name %in% input$selectCountry,]$Country.Code
            v$country_names <- input$selectCountry
        } else {
            v$country_codes <- filterCountryCodes(birthRate,input$selectRegion, input$checkGroup)
        }
    })

    # reset button
    observeEvent(input$reset, {
        df <- v$df
        df_meta <- v$df_meta
        updateSelectizeInput(session, "selectRegion",
                             choices = sort(unique(df_meta$Region)),
                             server = TRUE,
                             selected = NULL)
        updateSelectizeInput(session, "selectCountry",
                             choices = sort(unique(df$Country.Name)),
                             server = TRUE,
                             selected = NULL)
        updateSliderInput(session, "yearRange",
                          min = min(as.numeric(df$Year)),
                          max = max(as.numeric(df$Year)),
                          value = c(min(as.numeric(df$Year)),
                                    max(as.numeric(df$Year))))
        groups <- unique(df_meta$IncomeGroup)
        updateCheckboxGroupInput(session, "checkGroup",
                                 choices = groups,
                                 selected = groups)
        v$country_codes <- c()
        v$country_names <- c()
    })
    
    # Monitor selectRegion 
    observeEvent(input$selectRegion, {
        df <- v$df
        df_meta <- v$df_meta
        v$regions <- input$selectRegion
        codes <- filterCountryCodes(birthRate,input$selectRegion, input$checkGroup)
        updateSelectizeInput(session, "selectCountry",
                             choices = sort(unique(df[df$Country.Code %in% codes,]$Country.Name)),
                             server = TRUE)
    }, ignoreNULL=FALSE)
    
    # Monitor checkGroup 
    observeEvent(input$checkGroup, {
        df <- v$df
        df_meta <- v$df_meta
        codes <- filterCountryCodes(birthRate,input$selectRegion, input$checkGroup)
        updateSelectizeInput(session, "selectCountry",
                             choices = sort(unique(df[df$Country.Code %in% codes,]$Country.Name)),
                             server = TRUE)
    }, ignoreNULL=FALSE)
    
    # Switch tab panels
    observeEvent(input$tabsPanel, {
        if (input$tabsPanel == "Birth rate") {
            v$df <- birthRate@df
            v$df_meta <- birthRate@metadata
        } else if (input$tabsPanel == "Death rate") {
            v$df <- deathRate@df
            v$df_meta <- deathRate@metadata
        } else if (input$tabsPanel == "Fertility rate") {
            v$df <- fertilityRate@df
            v$df_meta <- fertilityRate@metadata
        } else if (input$tabsPanel == "Life expentancy") {
            v$df <- lifeRate@df
            v$df_meta <- lifeRate@metadata
        } else if (input$tabsPanel == "Life expentancy (Male)") {
            v$df <- lifeRate_m@df
            v$df_meta <- lifeRate_m@metadata
        } else if (input$tabsPanel == "Life expentancy (Female)") {
            v$df <- lifeRate_f@df
            v$df_meta <- lifeRate_f@metadata
        }
    })
    
    # Initialize selective input from 
    observe({
        df <- v$df
        df_meta <- v$df_meta
        
        min1 <- if (v$yearMin == 0) min(as.numeric(df$Year)) else v$yearMin
        max1 <- if (v$yearMax == 0) max(as.numeric(df$Year)) else v$yearMax
        updateSliderInput(session, "yearRange",
                          min = min(as.numeric(df$Year)),
                          max = max(as.numeric(df$Year)),
                          value = c(min1, max1))
        
        updateSelectizeInput(session, "selectRegion", 
                             choices = sort(unique(df_meta$Region)),
                             selected = v$regions)
        
        updateSelectizeInput(session, "selectCountry", 
                             choices = sort(unique(df$Country.Name)),
                             selected = v$country_names)
        
        groups <-unique(df_meta$IncomeGroup)
        updateCheckboxGroupInput(session, "checkGroup",
                                 choices = groups,
                                 selected = groups)
    })
    
    
    # Create mutlipelines chart for birth
    output$birthPLot <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                 df$Year <= v$yearMax &
                       df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Birth rate, crude (per 1,000 people)', 
                       xTitle = "Year", 
                       yTitle ="Birth Rate")
    })
    
    # Create mutlipelines chart for death
    output$deathPlot <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                           df$Year <= v$yearMax &
                           df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Death rate, crude (per 1,000 people)', 
                       xTitle = "Year", 
                       yTitle ="Death Rate")
    })
    
    # Create mutlipelines chart for death
    output$fertilityPlot <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                           df$Year <= v$yearMax &
                           df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Fertility rate, total (births per woman)', 
                       xTitle = "Year", 
                       yTitle ="Fertility Rate")
    })
    
    # Create mutlipelines chart for death
    output$lifePlot <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                           df$Year <= v$yearMax &
                           df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Life expectancy at birth, total (years)', 
                       xTitle = "Year", 
                       yTitle ="Lift Expentancy")
    })
    
    # Create mutlipelines chart for death
    output$lifePlot_m <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                           df$Year <= v$yearMax &
                           df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Life expectancy at birth, Male (years)', 
                       xTitle = "Year", 
                       yTitle ="Lift Expentancy")
    })
    
    # Create mutlipelines chart for death
    output$lifePlot_f <- renderPlotly({
        df <- v$df
        df_meta <- v$df_meta
        input_df <- df[df$Year >= v$yearMin &    
                           df$Year <= v$yearMax &
                           df$Country.Code %in%  v$country_codes,]
        plotyLineChart(input_df, 
                       chartTitle = 'Life expectancy at birth, Female (years)', 
                       xTitle = "Year", 
                       yTitle ="Lift Expentancy")
    })
})



