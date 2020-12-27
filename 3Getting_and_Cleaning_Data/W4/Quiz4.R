# Question 1 
# The American Community Survey distributes downloadable data about 
# United States communities. Download the 2006 microdata survey about housing 
# for the state of Idaho using download.file() from here: 
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv
# 
# and load the data into R. The code book, describing the variable names is here:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf 
# 
# Apply strsplit() to split all the names of the data frame on the characters 
# "wgtp". What is the value of the 123 element of the resulting list?

link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
data <- read.csv(link, sep = ",", header = TRUE)
result <- strsplit(names(data), split="wgtp")
result[123]


# Question 2
# Load the Gross Domestic Product data for the 190 ranked countries 
# in this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# 
# Remove the commas from the GDP numbers in millions of dollars and average them. 
# What is the average?
#     
#     Original data sources:
#     
#     http://data.worldbank.org/data-catalog/GDP-ranking-table

library(dplyr)
link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
data <- data.table::fread(link , skip=5, nrows = 190)
result <- link %>%
    data.table::fread(skip=5, nrows = 190) %>%
    select(c(1,2,4,5)) %>%
    rename(code = V1, ranking = V2, countryNames = V4, GDP =V5) %>%
    {as.numeric(gsub(",", "", .$GDP))} %>%
    mean

# Question 3
# In the data set from Question 2 what is a regular expression
# that would allow you to count the number of countries 
# whose name begins with "United"? Assume that the variable with 
# the country names in it is named countryNames.
# How many countries begin with United? 
library(dplyr)
link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
result <- link %>%
    data.table::fread(skip=5, nrows = 190) %>%
    select(c(1,2,4,5)) %>%
    rename(code = V1, ranking = V2, countryNames = V4, GDP =V5) %>%
    {grep("^United",.$countryNames)}


# Question 4
# Load the Gross Domestic Product data for the 190 ranked countries 
# in this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv 
# 
# Load the educational data from this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv
# 
# Match the data based on the country shortcode. Of the countries 
# for which the end of the fiscal year is available, how many end in June?
#     
#     Original data sources: 
#     
#     http://data.worldbank.org/data-catalog/GDP-ranking-table
# 
# http://data.worldbank.org/data-catalog/ed-stats
link1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
link2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
data1 <- link1 %>%
    data.table::fread(skip=5, nrows = 190) %>%
    select(c(1,2,4,5)) %>%
    rename(code = V1, ranking = V2, countryNames = V4, GDP =V5)

data2 <- link2 %>%
    data.table::fread(skip=4) %>%
    select(c(1,2,10)) %>%
    rename(code = V1, countryNames = V2, specialNotes = V10)
    
combine <- merge(x = data1,  y = data2, by = "code")

# Question 5
# You can use the quantmod (http://www.quantmod.com/) package to get historical 
# stock prices for publicly traded companies on the NASDAQ and NYSE. 
# Use the following code to download data on Amazon's 
# stock price and get the times the data was sampled.
# 
# library(quantmod) 
# amzn = getSymbols("AMZN",auto.assign=FALSE) 
# sampleTimes = index(amzn)
# 
# How many values were collected in 2012? 
# How many values were collected on Mondays in 2012?

library("quantmod")
amzn <- getSymbols("AMZN",auto.assign=FALSE)
# Wait 
sampleTimes <- index(amzn) 
df <- data_frame(sampleTimes = sampleTimes)

# How many values were collected in 2012? 
nrow(df[df$sampleTimes >= "2012-01-01"
        & df$sampleTimes < "2013-01-01",])

# How many values were collected on Mondays in 2012?
df$weekday <- weekdays(sampleTimes)
nrow(df[df$sampleTimes >= "2012-01-01"
        & df$sampleTimes < "2013-01-01"
        & df$weekday == "Monday",])



