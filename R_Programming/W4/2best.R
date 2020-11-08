

# 2 Finding the best hospital in a state
# reads the outcome-of-care-measures.csv file 
# and returns a character vector with the name of the hospital 
# that has the best (i.e. lowest) 30-day mortality for the specified outcome in that state.
best <- function(state, outcome) {
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
    # #filter na
    df <- df[!is.na(df[, outcome]),]
    # #convert the target column into numeric type
    df[, outcome] <- as.numeric(df[, outcome])
    #filter state
    df <- df[df[,"state"] == state, ]
    #sort the target column
    df <- df[order(df[, outcome]),]
    # get min
    min <- head(df[, outcome], 1)
    names <- df["hospital"][df[, outcome] == min,]
    return (sort(names)[1])
}