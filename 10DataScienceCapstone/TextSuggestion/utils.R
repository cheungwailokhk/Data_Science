# Load libraries
require(tm); require(SnowballC); require(stopwords); 
require(tokenizers);  require(tidyr); require(dplyr);  
require(plotly); require(ggplot2); require(wordcloud2); 

# Load txt file for training
loadData <- function (urls, samplePercent) {
    lines <- c()
    for (url in urls) {
        # Load data
        conn <- file(url,open="r")
        lines <- append(lines, readLines(url, warn=FALSE))
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

# Cleaning corpus
cleanCorpus <- function(myCorpus, removeStopwords = FALSE, 
                        isStemming = FALSE, isLemmatization = FALSE) {
    
    removeURL <- function(x) {gsub("(f|ht)tp(s?)://\\S+", "", x, perl=T)}
    removeSpecial <- function(x) {gsub("[^a-zA-Z ]+", "", x)} # except space
    removeEmpty <- function(x){!is.na(content(x)) & trimws(content(x)) != ""}
    
    # Preprocessing
    myCorpus <- tm_map(myCorpus, content_transformer(tolower))
    myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
    myCorpus <- tm_map(myCorpus, removePunctuation)
    myCorpus <- tm_map(myCorpus, removeNumbers)
    myCorpus <- tm_map(myCorpus, content_transformer(removeSpecial))
    
    if (removeStopwords) {
        myCorpus <- tm_map(myCorpus, removeWords, stopwords("english"))
    }
    # Remove documents with empty content to reduce size
    myCorpus <- tm_filter(myCorpus, removeEmpty)
    
    # Either Lemmatization or Stemming
    if (isStemming){
        myCorpus <- tm_map(myCorpus, stemDocument)
    }
    else if(isLemmatization) {
        require(textstem)
        myCorpus <- tm_map(myCorpus, content_transformer(lemmatize_strings))
    }
    myCorpus
}

# Create N-gram tern document matrix from a corpus
# lowfreq: all of the words which appear N times or more
createNgram <- function(myCorpus, ngram = 1, lowfreq = NA) {
    toToken <- function(x) {
        # x contains x[1]$content and x[2]$meta
        unlist(tokenize_ngrams(content(x), n = ngram, n_min = ngram))
    }
    
    # TDM automatically discards words less than three characters. 
    tdm <- TermDocumentMatrix(myCorpus, control = list(tokenize = toToken,
                                                       wordLengths=c(1, Inf)))
    if (!is.na(lowfreq)) {
        # filter words with N times or more 
        freqTerms <- findFreqTerms(tdm, lowfreq = lowfreq) 
        tdm <- tdm[freqTerms, ]
    }
    tdm
} 

# Convert a term document matrix to dataframe sorted by frequency
convertTdmToDf <- function(tdm) {
    # Reduce documents dimension and convert to dataframe
    # df <- data.frame(rowSums(as.matrix(tdm))) # exhaust memory
    df <- slam::row_sums(tdm, na.rm = T)
    df <- data.frame(word = names(df), freq = as.integer(df)) %>%
        arrange(desc(freq))
    print(paste0("Ngram size: ", format(object.size(df), units = "Mb")))
    df
}



# Unique words in a frequency sorted dataframe to cover of n% all words
calculateWordCoverage <- function(df, coveragePercent) {
    p<-cumsum(df$freq)/sum(df$freq)
    which(p>=coveragePercent)[1]
}


# Suggest word by the order of 7gram > 5gram > trigram > bigram
# N-grams are stored in dataframes already sorted by frequency
# return a list of words 
suggestWord <- function(N2gram, N3gram, N5gram, N7gram, sentence) {
    result <- data.frame()
    
    if (is.na(N2gram) || is.na(N3gram) || is.na(N5gram) || is.na(N7gram)) {
        return (result)
    }

    # apply same pre-processing steps
    sentence <- content(cleanCorpus(VCorpus(VectorSource(sentence)))[[1]])
    # check sentence's tokens 
    sentence_tokens <- unlist(tokenize_words(sentence))
    len <- length(sentence_tokens)
    
    if (len == 0) {return (result)}
    if (len >= 6) { 
        # 7gram
        sentence <- paste(sentence_tokens[(len-5):len],  collapse = " ")
        result <- N7gram[N7gram$firstPart==sentence,]
        if (length(dim(result)[1]) > 1) {return (result)}
    }
    if (len >= 4) {
        # 5gram
        sentence <- paste(sentence_tokens[(len-3):len],  collapse = " ")
        result <- N5gram[N5gram$firstPart==sentence,]
        if (length(dim(result)[1]) > 1) {return (result)}
    }
    if (len >= 2) {
        # Trigram
        sentence <- paste(sentence_tokens[(len-1):len],  collapse = " ")
        result <- N3gram[N3gram$firstPart==sentence,]$lastPart
        if (length(dim(result)[1]) > 1) {return (result)}
    }
    # Bigram
    sentence <- paste(sentence_tokens[len],  collapse = " ")
    result <- N2gram[N2gram$firstPart==sentence,]
    return (result)
}


plotWordCloud <- function(df, topN = 50, size = 0.5) {
    data <- head(df, topN) %>%
        mutate(word = paste(firstPart, lastPart, sep = " "),
               freq = freq) %>% 
            subset(select=c(word, freq))
    set.seed(1234)
    fig <- wordcloud2(data = data, color =  "random-dark",size = size)
    fig
}

# customed barchart for Ngram
plotyBarchart <- function(df, chartTitle, topN = 20, xTitle ="Words", yTitle = "Frequency") {
    data <- head(df, topN) %>%
        mutate(word = paste(firstPart, lastPart, sep = " ")) %>%
        subset(select=c(word, freq))
    
    data$word <- factor(data$word, 
                        levels = unique(data$word)[order(data$freq, decreasing = FALSE)])

    fig <- plot_ly(data, x = ~freq, y = ~word, 
                   type = "bar",
                   # type = 'scatter',mode   = 'markers',
                   height=max(400, dim(data)[1]*13))
    fig <- fig %>% layout(title = "Top suggestion",
                          xaxis = list(title = ""),
                          # yaxis = list(title = ""))
                          yaxis = list(title = "",tickmode='linear'))
    fig
}

