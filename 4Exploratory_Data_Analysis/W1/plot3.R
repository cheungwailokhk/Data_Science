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
library(ggplot2)
colors <- c("Sub_metering_1" = "black", 
            "Sub_metering_2" = "red", 
            "Sub_metering_3" = "blue")
ggplot(data = df, aes(x = TimeStamp)) +
    geom_line(aes(y = Sub_metering_1, color = "Sub_metering_1")) +
    geom_line(aes(y = Sub_metering_2, color = "Sub_metering_2")) +
    geom_line(aes(y = Sub_metering_3, color = "Sub_metering_3")) +
    labs(x = "",
         y = "Energy sub metering",
         color = "") +
    scale_color_manual(values = colors) +
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position = c(.95, .95),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(0, 0, 0, 0),
        legend.key = element_rect(colour = "transparent", fill = "white"),
    ) +
    scale_x_datetime(date_labels = "%a", date_breaks = "1 day")

## Copy to png
dev.copy(png,"plot3.png", width=480, height=480)
dev.off()