#   Author: cwl
#   Date: 15/06/2021
#   GitHub: https://github.com/cwl286/datasciencecoursera/tree/master/10DataScienceCapstone/TextSuggestion
#   
#   This source is to build the dataframe objects (./data/N2gram.rds, ./data/N3gram.rds, 
#   ./data/N5gram.rds, ./data/N7gram.rds)
# 
#
#
source("./utils.R")

# Corpus source: https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip
# Variables for corpus
url_tw <- "./data/en_US.twitter.txt"
url_blog <- "./data/en_US.blogs.txt"
url_news <- "./data/en_US.news.txt"
urls <- c(url_tw, url_blog, url_news)
samplePercent <- 1 # Sample percent

# Process corpus
corpus <- VCorpus(VectorSource(loadData(urls, samplePercent))) 
corpus <- cleanCorpus(corpus, 
                          removeStopwords = FALSE,
                          isStemming = FALSE,
                          isLemmatization = FALSE)
print(paste0('Corpus size after cleaning: ', format(object.size(corpus), units = "Mb")))

# Save corpus
saveRDS(corpus, "./data/corpus.rds")

# Load corpus
# corpus <- readRDS("./data/corpus.rds")

# train Ngram
ngrams <- c(2,3,5,7)
for (g in ngrams) {
    print(paste0("Now: N",as.character(g),"gram"))
    # lowfreq: all of the words which appear N times or more.
    df <- convertTdmToDf(createNgram(corpus, n = g, lowfreq = 2))
    # Split N-gram into two parts: first n-1 words and last word
    df <- df %>%
        separate(word,c("firstPart","lastPart"),sep=" (?=[^ ]*$)")
    saveRDS(df, paste0("./data/N",as.character(g),"gram",".rds"))
}

# Load Ngram
N2gram <- readRDS("./data/N2gram.rds")
N3gram <- readRDS("./data/N3gram.rds")
N5gram <- readRDS("./data/N5gram.rds")
N7gram <- readRDS("./data/N7gram.rds")

# Original file size
print(paste0('n gram: ', format(object.size(N2gram), units = "Mb")))
print(paste0('n gram: ', format(object.size(N3gram), units = "Mb")))
print(paste0('n gram: ', format(object.size(N5gram), units = "Mb")))
print(paste0('n gram: ', format(object.size(N7gram), units = "Mb")))

# Reduce file size, while keeping some coverage
df2 <- N2gram[1:calculateWordCoverage(N2gram,0.8),] # Bigram with 80% coverage = 10 Mb
df3 <- N3gram[1:calculateWordCoverage(N3gram,0.6),] # Trigram with 60% coverage = 25.4 Mb
df5 <- N5gram[1:calculateWordCoverage(N5gram,0.5),] # 5grams with 40% coverage = 50.8 Mb
df7 <- N7gram[1:calculateWordCoverage(N7gram,0.5),] # 7grams with 50% coverage = 37.6 Mb
saveRDS(df2, paste0("./data/N2gram",".rds"))
saveRDS(df3, paste0("./data/N3gram",".rds"))
saveRDS(df5, paste0("./data/N5gram",".rds"))
saveRDS(df7, paste0("./data/N7gram",".rds"))

