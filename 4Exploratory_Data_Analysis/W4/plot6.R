## Data preparation
## Download data
if (!file.exists("./summarySCC_PM25.rds") | !file.exists("./Source_Classification_Code.rds")){
    link <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(url = link,
                  destfile = './data.zip',
                  mode = 'wb')
    unzip(zipfile = "data.zip", exdir = getwd())
    file.remove('./data.zip')
    rm(link)
}

## Read data
NEI <- readRDS("./summarySCC_PM25.rds")
SCC <- readRDS("./Source_Classification_Code.rds")

## Prepare data
library(dplyr)

SCC_id <- SCC %>%
    filter(grepl('[Vv]ehicle', SCC.Level.Two))

totalEmission <- NEI %>%
    filter(fips == "24510" | fips == "06037") %>%
    inner_join(SCC_id, by = "SCC") %>%
    group_by(year, fips) %>%
    summarise(emissionByYear = sum(Emissions)) %>%
    arrange(year) %>%
    within(fips[fips == '06037'] <- 'LA') %>%
    within(fips[fips == '24510'] <- 'Baltimore City')

## Create a plot
library(ggplot2)
ggplot(totalEmission, aes(x = year,
                          y  = emissionByYear,
                          group = fips,
                          color = fips)) +
    geom_line() +
    labs(x = "year",
         y = "PM2.5 Emissions (tons)",
         caption = 'LA has seen greater changes over time in 
motor vehicle emissions') + 
    ggtitle("Total emissions from motor vehicle sources 
changed from 1999 to 2008 in Baltimore City & LA") +
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
    scale_color_brewer(palette="Set1")

## Copy to png
dev.copy(png,"plot6.png", width=480, height=480)
dev.off()
