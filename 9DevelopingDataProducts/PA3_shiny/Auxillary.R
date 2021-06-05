#   Author: cwl
#   Date: 03/06/2021
#   Data (03/06/2021) from the World Bank 
#
require(shiny);require(tidyr); require(dplyr); require(plotly); require(colorspace)

setClass(Class="data",
         representation(
             df="data.frame",
             metadata="data.frame"
         )
)

loadData <- function(url_data, url_metadata) {
    # Load data 
    df <- read.csv(url_data, na.strings=c("NA","#DIV/0!",""), skip=4)
    metadata = read.csv(url_metadata,sep=",",
                        na.strings=c("NA","#DIV/0!",""), 
                        stringsAsFactors = FALSE)
    
    # Medadata preprocessing
    metadata <- metadata %>%
        subset(select=c(Country.Code, Region, IncomeGroup)) %>%
        mutate(IncomeGroup = if_else(is.na(IncomeGroup), "Unknown", IncomeGroup))
    # Remove missing values
    metadata <- metadata[complete.cases(metadata), ]   
    
    # Data preprocessing
    df <- df  %>%
        subset(select=-c(Indicator.Name,Indicator.Code, X2020, X)) %>%
        pivot_longer(!c(Country.Name, Country.Code), names_to = "Year",
                     values_to = "Rate",
                     values_drop_na = TRUE)
    df$Year<-sub("^.", "", as.character(df$Year))
    rm(url_data,url_metadata)
    
    return (new("data",
                df=df,
                metadata=metadata))
}


filterCountryCodes <- function(data, select_regions, select_IncomeGroups)  {
    df <- data@df
    df_meta <- data@metadata
    country_codes <- unique(df$Country.Code)
    country_codes <- df_meta[df_meta$IncomeGroup %in% select_IncomeGroups, ]$Country.Code
    if (!is.null(select_regions)) {
        country_codes <- intersect(country_codes,df_meta[df_meta$Region %in% select_regions, ]$Country.Code)
    }
    #print(c(length(country_codes), select_regions))
    
    return (country_codes)
}



plotyLineChart <- function(df, chartTitle, xTitle, yTitle) {
    # mutlipelines chart
    fig <- plot_ly(df,x = ~Year, y = ~Rate, 
                   color=~Country.Name,
                   colors = diverge_hcl(260),
                   type = "scatter", mode = "lines")
    fig <- fig %>% layout(title = chartTitle,
                          xaxis = list(title = xTitle,
                                       zeroline = TRUE),
                          yaxis = list(title = yTitle))
    fig
}


