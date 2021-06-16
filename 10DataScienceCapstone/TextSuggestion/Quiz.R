#This source is to create Ngrams
source("./utils.R")


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
corpus <- readRDS("./data/corpus.rds")

# Read df
bigram <- readRDS("./data/bigram.rds")
bigram <- readRDS("./data/bigram.rds")
bigram <- readRDS("./data/bigram.rds")
trigram <- readRDS("./data/trigram.rds")
bigram <- readRDS("./data/bigram.rds")


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
    system(paste0("Say finished N",as.character(g),"gram"))
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

# Tasks 3
input <-c("case of", "about his", "me the", "but the", "at the", "on my",
          "quite some", "his little", "during the", "must be insensitive")
# apply same pre-processing steps
input <- cleanCorpus(VCorpus(VectorSource(input)))
trigram[grep(paste0("^", input[[1]]$content), trigram$word),] %>% arrange(freq)


# Tasks 4
input <-c("When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd",
          "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his",
          "I'd give anything to see arctic monkeys this",
          "Talking to your mom has the same effect as a hug and helps reduce your",
          "When you were in Holland you were like 1 inch away from me but you hadn't time to take a",
          "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the",
          "I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each",
          "Every inch of you is perfect from the bottom to the",
          "I’m thankful my childhood was filled with imagination and bruises from playing",
          "I like how the same people are in almost all of Adam Sandler's")

result <-  suggestWord(input[1]) # Unmatch
result[result$lastWord %in% c("give", "eat", "sleep", "die"),]
result <-  suggestWord(input[2]) # Unmatch
result[result$lastWord %in% c("financial", "martial", "spiritual", "horticultural"),]
result <-  suggestWord(input[3]) # Not the highest freq
result[result$lastWord %in% c("morning", "month", "weekend", "decade"),]
result <-  suggestWord(input[4])# Unmatch
result[result$lastWord %in% c("hunger", "happiness", "sleepiness", "stress"),]
result <-  suggestWord(input[5]) # Not the highest freq
result[result$lastWord %in% c("minute", "look", "picture", "walk"),]
result <-  suggestWord(input[6]) # Not the highest freq
result[result$lastWord %in% c("account", "matter", "case", "incident"),]
result <-  suggestWord(input[7]) # Correct
result[result$lastWord %in% c("arm", "toe", "hand", "finger"),]
result <-  suggestWord(input[8]) # Correct
result[result$lastWord %in% c("top", "side", "middle", "center"),]
result <-  suggestWord(input[9]) # Incorrect
result[result$lastWord %in% c("inside", "weekly", "daily", "outside"),]
result <-  suggestWord(input[10])# not found
result[result$lastWord %in% c("movies", "stories", "pictures", "novels"),]


# finally
# Reduce file, while keeping some coverage
df2 <- N2gram[1:calculateWordCoverage(N2gram,0.8),] # Bigram with 80% coverage = 10 Mb
df3 <- N3gram[1:calculateWordCoverage(N3gram,0.6),] # Trigram with 60% coverage = 25.4 Mb
df5 <- N5gram[1:calculateWordCoverage(N5gram,0.5),] # 5grams with 40% coverage = 50.8 Mb
df7 <- N7gram[1:calculateWordCoverage(N7gram,0.5),] # 7grams with 50% coverage = 37.6 Mb
saveRDS(df2, paste0("./data/N2gram",".rds"))
saveRDS(df3, paste0("./data/N3gram",".rds"))
saveRDS(df5, paste0("./data/N5gram",".rds"))
saveRDS(df7, paste0("./data/N7gram",".rds"))

