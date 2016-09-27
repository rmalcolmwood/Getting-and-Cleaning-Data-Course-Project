##Getting and Cleaning Data -  Final Assignment

##read the zipfile

filenm <- "getdata_dataset.zip"

if(!file.exists(filenm)){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, filenm)
}
##unzip
if(!file.exists("UCI HAR Dataset")) {
    unzip(filenm)
}

##read and set the activity labels/features from the unzipped file (use 2nd column only from
##the resulting table)
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features [,2] <- as.character(features[,2])

#read the mean and standard deviation
getmeanstd <- grep(".*mean.*|*.std.*", features[,2])
getmeanstd_nms <- features[getmeanstd,2]
getmeanstd_nms = gsub('-mean', 'Mean', getmeanstd_nms)
getmeanstd_nms = gsub('-std', 'Std', getmeanstd_nms)
getmeanstd_nms <- gsub('[-()]', '', getmeanstd_nms)

#read and merge the datasets and give them labels

traindata <- read.table("UCI HAR Dataset/train/X_train.txt")[getmeanstd]

train_activity <- read.table("UCI HAR Dataset/train/Y_train.txt") 
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt") 
traindata <- cbind(train_subject, train_activity, traindata)

testdata <- read.table("UCI HAR Dataset/test/X_test.txt")[getmeanstd] 
test_activity <- read.table("UCI HAR Dataset/test/Y_test.txt") 
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
testdata <- cbind(test_subject, test_activity, testdata)

mergedata <- rbind(traindata, testdata) 
colnames(mergedata) <- c("subject", "activity", getmeanstd_nms)

##make the activities & subjects into factors 
mergedata$activity <- factor(mergedata$activity, levels = activity[,1], labels = activity[,2]) 
mergedata$subject <- as.factor(mergedata$subject) 

##use the reshape2 package to name columns and get the means
mergedatamelt <- melt(mergedata, id = c("subject", "activity")) 
mergedatamean <- dcast(mergedatamelt, subject + activity ~ variable, mean) 
write.table(mergedatamean, "tidy.txt", row.names = FALSE, quote = FALSE)