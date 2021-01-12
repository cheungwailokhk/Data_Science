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
### Method 1
library(dplyr)
totalEmission <- NEI %>%
    group_by(year) %>%
    summarise(emissionByYear = sum(Emissions /10^6)) %>%
    arrange(year)

### Method 2
## totalEmission <- aggregate(Emissions ~ year, NEI, sum)

## Create a plot
with(totalEmission, 
     plot(x = year, 
          y = emissionByYear, 
          xlab="Year",
          ylab="PM2.5 Emissions (10^6 tons)",
          main = "Total PM2.5 Emissions from 1999 to 2008",
          cex.sub = 0.5,
          sub = "The total PM2.5 emission from all sources has decreased.",
          pch = 16
          ))


## Copy to png
dev.copy(png,"plot1.png", width=480, height=480)
dev.off()
