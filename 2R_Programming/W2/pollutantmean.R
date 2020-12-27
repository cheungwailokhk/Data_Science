# Part 1
#
# Write a function named 'pollutantmean' that calculates the mean of a pollutant
# (sulfate or nitrate) across a specified list of monitors. The function
# 'pollutantmean' takes three arguments: 'directory', 'pollutant', and 'id'.
# Given a vector monitor ID numbers, 'pollutantmean' reads that monitors'
# particulate matter data from the directory specified in the 'directory' 
# argument and returns the mean of the pollutant across all of the monitors, 
# ignoring any missing values coded as NA. A prototype of the function is 
# as follows

pollutantmean <- function(directory, pollutant, id = 1:332) {
  # Get and print current working directory.
  #print(getwd())
  
  # Set current working directory.
  #setwd(directory)
  
  # Create empty list to store pollutant vectors
  l1 <- list()
  
  #Loop id
  for (i in id) {
    df <- read.csv(paste0(directory,"/",formatC(i, width=3, flag="0"), ".csv"))
    l2 <- list(df[pollutant][!is.na(df[pollutant])])
    l1 <- list(l1, l2)
  }
  # Converting list numeric vector into a single vector
  # Calculate mean
  return(mean(unlist(l1)))
}


