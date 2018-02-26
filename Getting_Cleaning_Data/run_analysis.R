# Coursera - Johns Hopkins - Data Science - Getting and Cleaning Data
# Course Project

#TASKS
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load the necessary packages and get data
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "raw_data.zip"))
unzip(zipfile = "raw_data.zip")

# Load labels and features
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "feature_names"))
required_features <- grep("(mean|std)\\(\\)", features[, feature_names])
measurements <- features[required_features, feature_names]
measurements <- gsub('[()]', '', measurements)

# Load train datasets
x_train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, required_features, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
y_train <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("activity"))
subject_train <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("subject_number"))
x_train <- cbind(subject_train, y_train, train)

# Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, required_features, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
activity_test <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("activity"))
subject_test <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("subject_num"))
test <- cbind(subject_test, activity_test, test)

# Mrge datasets
combined <- cbind(x_train, test)

id_labels   = c("subject_num", "activity_ID", "activity_label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject_num + activity_label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")

