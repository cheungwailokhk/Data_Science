# a function called rankhospital that takes three arguments: 
# the 2-character abbreviated name of a state (state), an outcome (outcome), 
# and the ranking of a hospital in that state for that outcome (num). 
# The function reads the outcome-of-care-measures.csv file and returns a character vector
# with the name of the hospital that has the ranking specified by the num argument. 

rankhospital <- function(state, outcome, num = "best") { 
    ## Check that outcome are valid
    causes <-  c("heart attack", "heart failure", "pneumonia")
    if(!outcome %in% causes){
        stop('invalid outcome')
    }
    
    ## Read outcome data
    df <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    #Filter data
    df <- as.data.frame(cbind(df[, 2],  # hospital 
                              df[, 7],   # state
                              df[, 11],  # heart attack 
                              df[, 17],  # heart failure 
                              df[, 23]), # pneumonia
                        stringsAsFactors = FALSE)
    # Rename dataframe
    cnames <- c("hospital", "state", "heart attack", "heart failure", "pneumonia")
    colnames(df) <- cnames
    
    ## Check that state are valid
    if(!state %in% df[,"state"]){
        stop('invalid state')
    }
    
    ## Return hospital name in that state with lowest 30-day death
    #filter state
    df <- df[df[,"state"] == state, ]
    # #convert the target column into numeric type
    df[, outcome] <- as.numeric(df[, outcome])
    # #filter na
    df <- df[!is.na(df[, outcome]),]
    #sort the target column
    df <- df[order(df[, outcome], df[, "hospital"]),]
    
    #Return by rank
    if(num == "best") {
        num <- 1
    } else if (num == "worst") {
        num <- dim(df)[1]
    } 
    return (df["hospital"][num,])
}