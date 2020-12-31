## 1. Data preparation
## Download data

if (!file.exists('./household_power_consumption.txt')){
    link <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
    download.file(url = link,
                  destfile = './data.zip',
                  mode = 'wb')
    unzip(zipfile = "data.zip", exdir = getwd())
    file.remove('./data.zip')
    rm(link)
    
}
## Read data
df <- read.table('./household_power_consumption.txt', 
                   header = TRUE, sep = ";", na.strings = "?",
                 colClasses = c('character','character','numeric',
                                'numeric','numeric','numeric',
                                'numeric','numeric','numeric'))
## Clean data
df <- subset(df, Date == "1/2/2007" | Date == "2/2/2007")
df <- df[complete.cases(df),]
df$TimeStamp = paste(df$Date, df$Time, sep = " ")
## Convert data types
library(lubridate)
df$TimeStamp <- dmy_hms(df$TimeStamp)
# Remove useless columns
df = subset(df, select = -c(Date, Time))

## 2. Create png 
##  Create the plot
with(df, 
     hist(x = Global_active_power,
         main="Global Active Power",
         xlab = "Global Active Power(kilowatt)",
         ylab = "Frequency", col = "red")
    )
## Copy to png
dev.copy(png,"plot1.png", width=480, height=480)
dev.off()