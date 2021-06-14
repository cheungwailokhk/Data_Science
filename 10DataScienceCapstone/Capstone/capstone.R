source("./utils.R")

# Variables
url_tw <- "./data/en_US.twitter.txt"
url_blog <- "./data/en_US.blogs.txt"
url_news <- "./data/en_US.news.txt"
urls <- c(url_tw, url_blog, url_news)
samplePercent <- 0.6 # Sample percent

# Test
myCorpus <- VCorpus(VectorSource(c('lapply returns a list of the same length as X, each element of which is the result of applying FUN to the corresponding element ', 'hello word'))) 
myCorpus <- cleanCorpus(myCorpus, removeStopwords = FALSE)
View(data.frame(word=unlist(sapply(myCorpus, `[`, "content")), stringsAsFactors=F))

# Process all
corpus_all <- VCorpus(VectorSource(loadData(urls, samplePercent))) 
corpus_all <- cleanCorpus(corpus_all, 
                          removeStopwords = FALSE,
                          isStemming = FALSE,
                          isLemmatization = FALSE)

saveRDS(corpus_all, "./data/corpus_all.rds") # Save corpus

# Load corpus
corpus_all <- readRDS("./data/sample1/haveStopwords/corpus_all.rds")

# Check corpus content
View(data.frame(word=unlist(sapply(corpus_all, `[`, "content")), stringsAsFactors=F))

# Ngram
df7 <- createNgram(corpus_all, n = 7, lowfreq = 1)
saveRDS(df7, "./data/sevengram_1.rds")
rm(df7)

df5 <- createNgram(corpus_all, n = 5, lowfreq = 1)
saveRDS(df5, "./data/fivegram_1.rds")
rm(df5)

df3 <- createNgram(corpus_all, n = 3, lowfreq = 1)
saveRDS(df3, "./data/trigram_1.rds") # Save Ngram
rm(df3)

df2 <- createNgram(corpus_all, n = 2, lowfreq = 1)
saveRDS(df2, "./data/bigram_1.rds")
rm(df2)
