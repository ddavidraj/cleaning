## Creates a data set based upon the "UCI HAR Dataset" at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.
# The resulting data set contains all features from the training and test data sets, combined into a single data set.
# Activity labels and subjects are included for each row.
#
#  usage copy all the relevant files to the working directory and execute 
#  source("run_analysis.R")
#
setwd("d:/r/cd")
loadData <- function(nrows = 9999) {    # Read feature labels.  
  
  labels <- unlist(read.table("features.txt", header = FALSE, colClasses = c("NULL", NA), stringsAsFactors = FALSE))
  # Clean labels, remove invalid characters.
  labels <- gsub("[^a-zA-Z0-9]", "", labels)
  labels <- gsub("mean", "Mean", labels)
  labels <- gsub("std", "Std", labels)
  labels <- gsub("BodyBody", "Body", labels)
  # Read activity labels.   
  activityLabels <- read.table("activity_labels.txt", header = FALSE, col.names = c("activityCode", "activityLabel"), stringsAsFactors = FALSE)
  train <- read.table("train/X_train.txt", header = FALSE, nrows = nrows, col.names = labels, na.strings = "", stringsAsFactors = FALSE)  
  trainActivities <- read.table("train/y_train.txt", header = FALSE, nrows = nrows, col.names = c("activityCode"), na.strings = "", stringsAsFactors = FALSE) 
  trainActivities$activityLabel <- activityLabels$activityLabel[match(trainActivities$activityCode, activityLabels$activityCode)]        
  train$activity <- trainActivities$activityLabel        
  
  # Read train subjects.    
  subjects <- read.table("train/subject_train.txt", header = FALSE, nrows = nrows, col.names = c("subject"), na.strings = "", stringsAsFactors = FALSE)    
  train <- cbind(train, subjects)        
  test <- read.table("test/X_test.txt", header = FALSE, nrows = nrows, col.names = labels, na.strings = "", stringsAsFactors = FALSE)        
  testActivities <- read.table("test/y_test.txt", header = FALSE, nrows = nrows, col.names = c("activityCode"), na.strings = "", stringsAsFactors = FALSE)    
  testActivities$activityLabel <- activityLabels$activityLabel[match(testActivities$activityCode, activityLabels$activityCode)]        
  test$activity <- testActivities$activityLabel  
  
  # Read test subjects.    
  subjects <- read.table("test/subject_test.txt", header = FALSE, nrows = nrows, col.names = c("subject"), na.strings = "", stringsAsFactors = FALSE)
  test <- cbind(test, subjects)          
  data <- rbind(train, test)
  
  }
## Extracts all columns from the data set that relate to mean and standard deviation features.
#
createMeanStdData <- function(data)
  {    # Remove all columns except for activity, mean, and standard deviations.    
  data <- data[, grep("subject|activity|Mean|Std", names(data))]   
  removeColumns <- names(data[, grep("angle", names(data))])      
  removeColumns <- c(removeColumns, names(data[, grep("Freq", names(data))]))
  # Remove columns.    
  data <- data[ , -which(names(data) %in% removeColumns)]   
  # Return result.
  data
  }
#
# Creates a tidy data set with the average of each variable for each activity and subject.
#
createTidyData <- function(data)
  {    # Create a tidy data frame for the result.   
  result <- data.frame(stringsAsFactors = FALSE)
  # Split the data into groups by subject.
  dataBySubject <- split(data, data$subject)    
  # Split the group further into groups by activity.    
  dataBySubjectAndActivity <- lapply(dataBySubject, function(e) split(e, e$activity))    
  # For each subject in length(dataBySubjectAndActivity), enumerate each activity length(dataBySubjectAndActivity[[1]]).    
  # Iterate over each subject/activity group. 
  lapply(dataBySubjectAndActivity, function(subjectGroup) {       
    # Iterate over each activity in the group.        
    lapply(subjectGroup, function(subjectActivityGroup)
      {            # Create a row. Note, we put the subject and activity at the front.            
      row <- data.frame(subject = integer(), activity = character(), stringsAsFactors = FALSE)    
      # Iterate over each column by index. This way we can access the column names as well as the data.            
      lapply(seq_along(subjectActivityGroup), function(i) {       
        if (i < 67) {                   
          # This is a feature column, so calculate the mean for this subject/activity and set the value in the cell.                    
          row[1, names(subjectActivityGroup[i])] <<- mean(subjectActivityGroup[[i]])
          }                
        else {                    
          # This is a subject or activity column. Set the value in the cell.
          row[1, names(subjectActivityGroup[i])] <<- subjectActivityGroup[[i]][1]
          }           
        }
        )                   
      # Append the resulting row to our result data frame.    
      result <<- rbind(result, row)     
      })    
    })        # Return result.
  result
  }
# Load train and test data into a single data set.
data <- loadData()
# Get all columns relating to mean and standard deviation.
meanStdData <- createMeanStdData(data)
# Create a tidy data set with the average of each variable for each activity and each subject.
tidyData <- createTidyData(meanStdData)
# Write output file 1.
write.csv(meanStdData, "meanStd.csv", quote=FALSE, row.names=FALSE)
# Write output file 2.
#write.csv(tidyData, "tidy.csv", quote=FALSE, row.names=FALSE)
options(width=1000)
write.table(tidyData, file = "tidy.txt", sep = "  ", col.names = colnames(tidyData) )
