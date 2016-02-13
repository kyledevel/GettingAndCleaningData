require(dplyr)

# Downloads dataset and unzips it into working directory
if (!file.exists("data.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                "data.zip")
}

if (!file.exists("UCI HAR Dataset")) {
  unzip("data.zip")
}

# Reads test group data
subject.test <- read.table("UCI HAR Dataset/test/subject_test.txt")
x.test <- read.table("UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("UCI HAR Dataset/test/y_test.txt")

# Reads train group data
subject.train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x.train <- read.table("UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("UCI HAR Dataset/train/y_train.txt")

# Combines test and train data into a single data frame
# Col1 = subject ID, Col2 = Y (acitivity) data, Col3:n = X (measurement) data
data <- rbind(cbind(subject.test, y.test, x.test),
              cbind(subject.train, y.train, x.train))

# Reads and assigns default column names in features.txt to data frame
features <- read.table("UCI HAR Dataset/features.txt")
features$V2 <- as.character(features$V2)
colnames(data) <- c("subject", "activity", features$V2)

# Subsets data that contains mean or std measurements
data <- data[, c(1:2, grep("mean\\(|std\\(", colnames(data)))]

# Label activity identifiers with descriptive labels
activity.labels <- read.table("UCI HAR Dataset/activity_labels.txt")
data$activity <- activity.labels[data$activity, 2]

# Cleans data column names
# Changes "-" to "." and removes parentheses
# Changes axis labels to lower case
colnames(data) <- gsub("-|\\(\\)-", ".", colnames(data))
colnames(data) <- gsub("\\(\\)", "", colnames(data))
colnames(data) <- gsub("X", "x", colnames(data))
colnames(data) <- gsub("Y", "y", colnames(data))
colnames(data) <- gsub("Z", "z", colnames(data))

# Generates separate clean data frame with the average of each variable for each
# activity and each subject
final <- summarize_each(group_by(data, subject, activity), funs(mean))

# Generates codebook
promptData(final, "CodeBook.Rd")

# Exports tidy data as a space-delimited text file
write.table(final, "tidy.txt", row.names = FALSE)