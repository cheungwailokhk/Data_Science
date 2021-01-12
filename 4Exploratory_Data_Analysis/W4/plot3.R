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

totalEmission <- NEI %>%
    filter(fips == "24510") %>%
    group_by(year, type) %>%
    summarise(emissionByYear = sum(Emissions /10^6 )) %>%
    arrange(year)

## Create a plot
library(ggplot2)
ggplot(totalEmission, aes(x = year,
                        y  = emissionByYear,
                        group = type,
                        color = type)) +
    geom_line() +
    labs(x = "year",
         y = "PM2.5 Emissions (10^6 tons)",
         caption = 'All sources decreased between 1999 and 2008 except "POINT",
which increased emissions from 1999 to 2005.') + 
    ggtitle("Total Emissions By Type In Baltimore City, 
Maryland From 1999 - 2008") +
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
    scale_color_brewer(palette="Set1")

## Copy to png
dev.copy(png,"plot3.png", width=480, height=480)
dev.off()
