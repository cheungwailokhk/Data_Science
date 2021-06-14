# Load libraries
require(tm); require(SnowballC); require(stopwords); 
require(tokenizers);  require(dplyr); require(textstem)
#require(ggplot2); require(wordcloud2); require(webshot); require(htmlwidgets);


loadData <- function (urls, samplePercent) {
    lines <- c()
    for (url in urls) {
        # Load data
        conn <- file(url,open="r")
        lines <- append(lines, readLines(url))
        close(conn)
    }
    # Sampling
    set.seed(1234)
    lines <- sample(lines, length(lines)*samplePercent, replace=FALSE)
    
    # Print out file information
    print(data.frame('Lines_counts' = length(lines), 
                     'Word_counts' = sum(nchar(lines)), 
                     'File_size' = format(object.size(lines), units = "Mb"),
                     row.names = c("Data")
                     ))
    lines
}

# Text cleaning
cleanCorpus <- function(myCorpus, removeStopwords = FALSE, 
                        isStemming = FALSE, isLemmatization = FALSE) {
    
    removeURL <- function(x) {gsub("(f|ht)tp(s?)://\\S+", "", x)}
    removeSpecial <- function(x) {gsub("[^[:alnum:] ]", "", x)} 

    # Preprocessing
    myCorpus <- tm_map(myCorpus, content_transformer(tolower))
    myCorpus <- tm_map(myCorpus, removePunctuation)
    myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
    myCorpus <- tm_map(myCorpus, removeNumbers)
    myCorpus <- tm_map(myCorpus, content_transformer(removeSpecial))
    
    if (removeStopwords) 
        myCorpus <- tm_map(myCorpus, removeWords, stopwords("english"))
    
    # Either Lemmatization or Stemming
    if (isStemming)
        myCorpus <- tm_map(myCorpus, stemDocument)
    else if(isLemmatization)
        require(textstem)
        myCorpus <- tm_map(myCorpus, content_transformer(lemmatize_strings))
    
    print(paste0('Corpus size after cleaning: ', format(object.size(myCorpus), units = "Mb")))
    myCorpus
}

# create term document matrix by n gram
createNgram <- function(myCorpus, ngram = 1, lowfreq = NA) {
    toToken <- function(x) {
        # x is a corpus which contains x[1]$content and x[2]$meta
        unlist(tokenize_ngrams(x[1]$content, n = ngram, n_min = ngram))
    }
    
    # TDM automatically discards words less than three characters. 
    tdm <- TermDocumentMatrix(myCorpus, control = list(tokenize = toToken,
                                                       wordLengths=c(1, Inf)))

    if (!is.na(lowfreq)) {
        # remove infrequent words to reduce size
        freqTerms <- findFreqTerms(tdm, lowfreq = lowfreq)
        tdm <- tdm[freqTerms, ]
    }
    
    # Reduce documents dimension and convert to dataframe
    # df <- data.frame(rowSums(as.matrix(tdm))) # exhaust memory
    df <- slam::row_sums(tdm, na.rm = T)
    df <- data.frame(word = names(df), freq = as.integer(df)) %>%
        arrange(word)
    rm(tdm)

    # Calculate probability (word frequency/ total frequency)
    totalFreq <- sum(df$freq)
    df <- df %>% mutate(probability = freq/totalFreq)
    print(paste0("Ngram size: ", format(object.size(df), units = "Mb")))
    df
} 





