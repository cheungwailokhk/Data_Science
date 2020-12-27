# Part 3
# 
# Write a function that takes a directory of data files and a threshold for 
# complete cases and calculates the correlation between sulfate and nitrate
# for monitor locations where the number of completely observed cases
# (on all variables) is greater than the threshold. The function should 
# return a vector of correlations for the monitors that meet the threshold
# requirement. If no monitors meet the threshold requirement, then the 
# function should return a numeric vector of length 0. 
# A prototype of this function follows
# 


source("corr.R")
source("complete.R")

corr <- function(directory, threshold = 0) {
  result <- numeric(0)
  nobs_df <- complete("specdata")
  nobs_df <- nobs_df[nobs_df$nobs > threshold,]
  
  for (i in nobs_df$id) {
    data_df <- read.csv(paste0(directory,"/",formatC(i, width=3, flag="0"), ".csv"))
    result <- c(result, cor(data_df$sulfate, data_df$nitrate, use = "pairwise.complete.obs"))
  }
  
  return(result)
}

