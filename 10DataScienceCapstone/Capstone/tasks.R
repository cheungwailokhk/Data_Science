source("./utils.R")


# Read df
trigram <- readRDS("./data/Sample1/haveStopwords/trigram_1.rds")
print(paste0("Dataframe size: ", format(object.size(trigram), units = "Mb")))

bigram <- readRDS("./data/Sample1/haveStopwords/bigram_1.rds")
print(paste0("Dataframe size: ", format(object.size(bigram), units = "Mb")))

# Tasks 3
input <-c("case of", "about his", "me the", "but the", "at the", "on my",
          "quite some", "his little", "during the", "must be insensitive")
# apply same pre-processing steps
input <- cleanCorpus(VCorpus(VectorSource(input)))
trigram[grep(paste0("^", input[[1]]$content), trigram$word),] %>% arrange(freq)

# Tasks 4
input <-c("and I'd", "about his,", "reduce your",
          "take a", "settle the", "in each",
          "to the", "from playing","Adam Sandlers")
# apply same pre-processing steps
input <- cleanCorpus(VCorpus(VectorSource(input)))
trigram[grep(paste0("^", input[[7]]$content, 'give'), trigram$word),] %>% 
    arrange(freq)

bigram[grep(paste0("^", 'adam'), bigram$word),] %>% 
    arrange(freq)

