#Load csv
outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
head(outcome)

# # Get info
# ncol(outcome) 
# names(outcome)
# str(outcome)

# 1 Plot the 30-day mortality rates for heart attack
outcome[, 11] <- as.numeric(outcome[, 11])
hist(outcome[, 11]
     ,xlab='Deaths'
     ,main='Hospital 30-Day Death (Mortality) Rates from Heart Attack'
     ,col="lightblue")