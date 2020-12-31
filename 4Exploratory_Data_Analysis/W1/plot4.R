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
##  Create plots
library(ggplot2)
plot1 <- ggplot(df, aes(x = TimeStamp,
               y  = Global_active_power)) +
    geom_line() +
    labs(x = "",
         y = "Global Active Power (kilowatts)",
         color = "") + 
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
    scale_x_datetime(date_labels = "%a", date_breaks = "1 day")

plot2 <- ggplot(df, aes(x = TimeStamp,
                        y  = Voltage)) +
    geom_line() +
    labs(x = "datetime",
         y = "Voltage (volt)",
         color = "") + 
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
    scale_x_datetime(date_labels = "%a", date_breaks = "1 day")


colors <- c("Sub_metering_1" = "black", 
            "Sub_metering_2" = "red", 
            "Sub_metering_3" = "blue")
plot3 <- ggplot(data = df, aes(x = TimeStamp)) +
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

plot4 <- ggplot(df, aes(x = TimeStamp,
                        y  = Global_reactive_power)) +
    geom_line() +
    labs(x = "datetime",
         y = "Global Rective Power (kilowatts)",
         color = "") + 
    theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
    scale_x_datetime(date_labels = "%a", date_breaks = "1 day")

## Prepare environment
# install.packages("gridExtra")
library(gridExtra)
grid.arrange(plot1, plot2, plot3, plot4,
             ncol = 2, nrow = 2)
## Copy to png
dev.copy(png,"plot4.png", width=480, height=480)
dev.off()