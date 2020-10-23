#https://www.coursera.org/learn/r-programming/home/week/1

#Q11
x <- read.csv("hw1_data.csv")

# Q12
head(x,2)

# Q13
dim(x)

# Q14
tail(x, 2)

# Q15
x[47,"Ozone"]


# Q16
bad <- is.na(x["Ozone"])
table(bad)

# Q17
x <- read.csv("hw1_data.csv")
mean(x["Ozone"][!is.na(x["Ozone"])])

# Q18
x <- read.csv("hw1_data.csv")
good <- complete.cases(x["Solar.R"], x["Ozone"], x["Temp"])
mean(x$Solar.R[good & x$Ozone >31 & x$Temp > 90])

# Q19
x <- read.csv("hw1_data.csv")
good <- complete.cases(x["Month"], x["Ozone"])
max(x$Ozone[good & x$Month == 5])


x <- list(2, "a", "b", TRUE)
x[[1]]
