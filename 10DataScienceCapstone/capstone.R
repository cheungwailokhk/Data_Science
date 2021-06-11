fileName <- "./data/en_US.twitter.txt"
conn <- file(fileName,open="r")
linn <-readLines(conn)

count1 <- sum(as.numeric(grep("love", linn, ignore.case = FALSE)))
count2 <- sum(as.numeric(grep("hate", linn), ignore.case = FALSE))

counts1/count2

grep("biostats", linn, value = TRUE)

length(grep("A computer once beat me at chess, but it was no match for me at kickboxing", linn))
close(conn)