##Usage

Download All the relevant files to the working directory, and the source code to the working directory and execute source("run_analysis.R")
The program produces the following two files: meanStd.csv and tidy.txt which is comma seperated.

 ##Output

 meanStd.csv

Contains the merged set of train and test data, extracting only features relating to mean and standard deviation measurements (-mean() and -std() columns). Each row is labelled with a descriptive activity name. Each column is labelled with a descriptive feature name, sourced from UCI HAR Dataset/features.txt.



##tidy.csv

Contains a tidy data set from the merged set of train and test data. The tidy data set contains the average of each feature from meanStd.csv for each activity and each subject. Data is displayed in a wide table format, with each column including a specific feature, and each row including a subject/activity combination.

The original data set contains 30 subjects and 6 activities. A row exists in the tidy data set for each subject's activity. This results in 6 rows per subject, displaying the average (mean) value for each feature.


