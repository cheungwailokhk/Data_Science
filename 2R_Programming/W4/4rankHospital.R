library(dplyr)

# The function reads the outcome-of-care-measures.csv file and returns a 2-column 
# data frame containing the hospital in each state that has the ranking specified
# in num. 
# num = hospital ranking
rankall<- function(outcome, num = "best") {
    
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
    # #convert the target column into numeric type
    df[, outcome] <- as.numeric(df[, outcome])
    # #filter na
    df <- df[!is.na(df[, outcome]),]
    
    
    df2 <- df %>%
        select(hospital= hospital, state= state, outcome= contains(outcome)) %>%
        group_by(state) %>%
        arrange(state, outcome, hospital) %>%
        mutate(rank= row_number())
    
    ## Return a data frame with the hospital names and the
    ## (abbreviated) state name
    
    result <- data.frame()
    
    for (state in sort(unique(df[,"state"]))) {
        
        #Return by rank
        if(num == "best") {
            num <- 1
        } else if (num == "worst") {
            num <- max(df2[df2[,"state"] == state, ]["rank"])
        }
        
        #Check if hospital exits
        hospital <- unlist(df2[df2[,"state"] == state &df2[,"rank"] == num, ]["hospital"])
        hospital <- ifelse(!identical(character(0), hospital), hospital, "<NA>")
        #Append to result
        result <- rbind(result,
                       data.frame(hospital = hospital,
                                  state = state))
    }
    return(result)
}

