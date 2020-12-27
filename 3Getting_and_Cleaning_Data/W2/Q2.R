library(sqldf)
##Q1
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
#download.file(url, destfile = "./Quiz2.csv", method = "curl")
acs <-  read.table(url, sep = ",", header = TRUE) 
q1 <- sqldf("select pwgtp1 from acs where AGEP < 50")
## read.csv.sql(url, "select pwgtp1 from file where AGEP < 50")

##Q3
conn <- url("http://biostat.jhsph.edu/~jleek/contact.html")
html <- readLines(conn)
close(conn)

nchar(html[10])
nchar(html[20])
nchar(html[30])
nchar(html[100])