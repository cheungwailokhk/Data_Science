## Q1
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
## download.file(url, destfile = "./Dataset/Quiz1-01.csv", method = "curl")

## Q1 method1
data <-  read.table(url, sep = ",", header = TRUE) 
sum(data$VAL == 24, na.rm = TRUE)

## Q1 method2
library(dplyr)
data2 <- tbl_df(data)
count(filter(select(data2, VAL), VAL==24, !is.na(VAL)))
#or 
count(filter(select(data2, VAL), VAL==24))




## Q2
library(xlsx)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
dat <- read.xlsx(xlsxFile= url, sheetIndex=1, colIndex = 18:23, rowIndex = 7:15)
sum(dat$Zip*dat$Ext,na.rm=T)

## Q3
library(XML)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
tree <- xmlTreeParse(sub("s", "", url), useInternal=TRUE)
rootNode <- xmlRoot(tree)
zip <- xpathSApply(rootNode, "//zipcode", xmlValue)
sum(zip == 21231)


## Q4
library(data.table)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
DT <- fread(url)
DT


system.time(mean(DT[DT$SEX==1,]$pwgtp15), mean(DT[DT$SEX==2,]$pwgtp15))
system.time(DT[,mean(pwgtp15),by=SEX])
system.time(sapply(split(DT$pwgtp15,DT$SEX),mean))
system.time(tapply(DT$pwgtp15,DT$SEX,mean))
system.time(mean(DT$pwgtp15,by=DT$SEX))
system.time(rowMeans(DT)[DT$SEX==1], rowMeans(DT)[DT$SEX==2]) ## Error in rowMeans(DT) : 'x' must be numeric



