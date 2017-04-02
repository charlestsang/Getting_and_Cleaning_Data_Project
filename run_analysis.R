#Download and extract source data from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#Check working environment
getwd()
#Check avaliable data files for assignment, contains:
#1.README.MD
#2.CODE_BOOK.MD
#3.Original data datasets "UCI\ HAR\ Dataset"
# set working environment to the assignment folder
setwd("./UCI HAR Dataset")
# Check avaliable files
dir()

###################################################################
# 1. Merges the training and the test sets to create one data set.
df1 <- read.table("train/X_train.txt")
df2 <- read.table("test/X_test.txt")
df3 <- read.table("train/subject_train.txt")
df4 <- read.table("test/subject_test.txt")
df5 <- read.table("train/y_train.txt")
df6 <- read.table("test/y_test.txt")
train_data <- cbind(cbind(df1, df3), df5)
test_data <- cbind(cbind(df2, df4), df6)
sensor_data <- rbind(train_data, test_data)

###################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

head(sensor_data)
#check data file structures: 563 columns; 1-561 columns = train_data (561 features), 562 column = Subject, 563 column = test_data
str(sensor_data)
#Apply featurs to the dataset to get labels names
features <- read.table("./features.txt")
names(sensor_data) <- rbind(rbind(features, c(562, "Subject"), c(563, "ActivityId")))[, 2]
#Meet warning information, go ahead by ignoring "NA" values
sensor_data_mean_std <- sensor_data[,grepl("mean|std|Subject|ActivityId", names(sensor_data))]
#Check mean std infomation
sensor_data_mean_std 

###################################################################
#3. Uses descriptive activity names to name the activities in the data set
activities <- read.table("activity_labels.txt")
activities[, 2] = gsub("_", "", tolower(as.character(activities[, 2])))
activities
sensor_data[,563] = activities[sensor_data[,563] , 2]
Y <- sensor_data[,563]
names(Y) <- "activity"

###################################################################
#4. Appropriately labels the data set with descriptive variable names.
# Remove parentheses
names(sensor_data) <- gsub('\\(|\\)',"",names(sensor_data), perl = TRUE)
# Make syntactically valid names
names(sensor_data) <- make.names(names(sensor_data))
# Make clearer names
names(sensor_data) <- gsub('Acc',"Acceleration",names(sensor_data))
names(sensor_data) <- gsub('GyroJerk',"AngularAcceleration",names(sensor_data))
names(sensor_data) <- gsub('Gyro',"AngularSpeed",names(sensor_data))
names(sensor_data) <- gsub('Mag',"Magnitude",names(sensor_data))
names(sensor_data) <- gsub('^t',"TimeDomain.",names(sensor_data))
names(sensor_data) <- gsub('^f',"FrequencyDomain.",names(sensor_data))
names(sensor_data) <- gsub('\\.mean',".Mean",names(sensor_data))
names(sensor_data) <- gsub('\\.std',".StandardDeviation",names(sensor_data))
names(sensor_data) <- gsub('Freq\\.',"Frequency.",names(sensor_data))
names(sensor_data) <- gsub('Freq$',"Frequency",names(sensor_data))

df_sensor_data <- data.frame(sensor_data)
colnames(df_sensor_data)[562] <- "Subject"
colnames(df_sensor_data)[563] <- "Activity"
names(df_sensor_data) 
write.table(df_sensor_data, "merged_data.txt")
head(df_sensor_data)

###################################################################
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#use "plyr" package
install.packages("plyr")
library(plyr)
#Hadely's plyr package provides an elegant wrapper with the ddply function. 
#assign_variable <- ddply(df, "labels", transform)
sensor_avg_by_act_sub = ddply(df_sensor_data, c("Subject","Activity"), numcolwise(mean))
write.table(sensor_avg_by_act_sub, file = "sensor_avg_data.txt")

head(sensor_avg_by_act_sub)

