## 0. Data preparation
link <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./data')){
    dir.create("./data")
    download.file(url = link,
                  destfile = './data.zip',
                  mode = 'wb')
    unzip(zipfile = "data.zip", exdir = getwd())
    file.rename(from = "UCI HAR Dataset",
                to = "data")
    file.remove('./data.zip')
}

## read data
features_table <- read.table('./data/features.txt', header = FALSE)
features_table <- as.character(features_table[,2])

train_subject_table <- read.table('./data/train/subject_train.txt', 
                                  header = FALSE)
train_x_table <- read.table('./data/train/X_train.txt', header = FALSE)
train_y_table <- read.table('./data/train/y_train.txt', header = FALSE)

test_subject_table <- read.table('./data/test/subject_test.txt', 
                                 header = FALSE)
test_x_table <- read.table('./data/test/X_test.txt', header = FALSE)
test_y_table <- read.table('./data/test/y_test.txt', header = FALSE)

# Create tables
train_table <-  cbind(train_subject_table, train_y_table, train_x_table)
test_table <-  cbind(test_subject_table, test_y_table, test_x_table)

## 1. Merges the training and the test sets to create one data set.
data_table <- rbind(train_table, test_table)
names(data_table) <- c(c('subject', 'activity_index'), features_table)

# Remove useless tables
rm(train_subject_table, train_y_table, train_x_table)
rm(test_subject_table, test_y_table, test_x_table)
rm(train_table, test_table, features_table)

## 2. Extracts only the measurements on the mean and standard deviation 
# for each measurement. 
data_table <- data_table[ , grepl( "subject|activity_index|mean|std" , 
                                   names(data_table))]


## 3. Uses descriptive activity names to name the activities in the data set
activity_lookup_table <- read.table('./data/activity_labels.txt', header = FALSE)
names(activity_lookup_table) <- c("activity_index", "activity_label")

# merge all rows from x where there are matching values in y, 
#  and all columns from x and y
library(dplyr)
data_table <- data_table %>% inner_join(activity_lookup_table, 
                                        by = "activity_index")
data_table <- select(data_table, -activity_index) 

## 4. Appropriately labels the data set with descriptive variable names.
# reference ./data/features_info.txt
col_names <- names(data_table)
# replace parenthesis
col_names <- gsub("[()]", "", col_names)
col_names <- gsub("-", "_", col_names)
col_names <- gsub("^f", "frequency_domain_", col_names)
col_names <- gsub("^t", "time_domain_", col_names)
col_names <- gsub("Body", "body_", col_names)
col_names <- gsub("Gravity", "gravity_", col_names)
col_names <- gsub("Gyro", "gyroscope_", col_names)
col_names <- gsub("std", "standard_deviation_", col_names)
col_names <- gsub("Mag", "magnitude_", col_names)
col_names <- gsub("Acc", "accelerometer_", col_names)
col_names <- gsub("Freq", "frequency", col_names)
names(data_table) <- col_names

# 5. From the data set in step 4, creates a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.
tidy_data_table <-
    data_table %>%
    group_by(activity_label, subject) %>%
    summarise_all(list(mean))

write.table(tidy_data_table, file = "tidy_data.csv", 
            sep = ",", 
            row.names = FALSE,
            col.names = TRUE,
            qmethod = "double")