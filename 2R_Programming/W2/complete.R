# Part 2
# 
# Write a function that reads a directory full of files and reports the number of
# completely observed cases in each data file. The function should return a dataframe
# where the first column is the name of the file and the second column is the number
# of complete cases. A prototype of this function follows
# 


complete <- function(directory, id = 1:332) {
  # Get and print current working directory.
  #print(getwd())
  
  # Set current working directory.
  #setwd(directory)
  
  # Create empty dataframe to store result
  result2 <- data.frame(id=numeric(), nobs=numeric())

  # Create empty vector to store id 
  col1 <- vector()
  # Create empty vector to store nobs 
  col2 <- vector()

  #Loop id
  for (i in id) {
    df <- read.csv(paste0(directory,"/",formatC(i, width=3, flag="0"), ".csv"))
    nob <- nrow(df[complete.cases(df), ])
    col1 <- append(col1,i)
    col2 <- append(col2,nob)
  }
  return(data.frame(id = col1, nobs = col2))
}


