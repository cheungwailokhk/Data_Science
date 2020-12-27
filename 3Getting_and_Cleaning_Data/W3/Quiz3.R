## Q1
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
data <-  read.table(url, sep = ",", header = TRUE)
agricultureLogical <- data$ACR == 3 & data$AGS == 6
which(agricultureLogical)


## Q2
## install.packages("jpeg")
library(jpeg)
img <- readJPEG('getdata_jeff.jpg', native=TRUE)
quantile(img, probs=c(0.3, 0.8), na.rm=TRUE)


## Q3
url1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
url2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
data1<-data.table::fread(url1)
data2<-data.table::fread(url2 , skip=4, nrows = 190)

combine <- merge(x = data1,  y = data2, by.x = "V1", by.y = "V1")

