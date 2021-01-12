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
    group_by(year) %>%
    summarise(emissionByYear = sum(Emissions /10^6)) %>%
    arrange(year)

## Create a plot
with(totalEmission, 
     plot(x = year, 
          y = emissionByYear, 
          xlab="Year",
          ylab="PM2.5 Emissions (10^6 tons)",
          main = "Total PM2.5 Emissions in Baltimore City from 1999 to 2008",
          cex.sub = 0.5,
          sub = "Total emissions from all sources in Baltimore City,decreased from 1999 to 2002, 
          increased from 2002 to 2005, then decreased from 2005 to 2008.",
          pch = 16
     ))

## Copy to png
dev.copy(png,"plot2.png", width=480, height=480)
dev.off()
