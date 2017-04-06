filename <- "./data/dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL, filename, method="curl")
unzip(filename)

# Read train data:
x_train<-read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Read test data:
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Read features:
features<-read.table("./data/UCI HAR Dataset/features.txt",colClasses = "character")

# Read activity labels:
activity_labels<-read.table("./data/UCI HAR Dataset/activity_labels.txt")

# Bind train and test data
training_data<-cbind(cbind(x_train,subject_train),y_train)
test_data<-cbind(cbind(x_test,subject_test),y_test)
merged_data<-rbind(training_data,test_data)
merged_labels<-rbind(rbind(features,c(562,"subjectID")),c(563,"activityID"))[,2]
colnames(merged_data)<-merged_labels

# Extract mean and std deviation for each measurement
merged_data_mean_std<-merged_data[,grepl("mean|std|subjectID|activityID",colnames(merged_data))]

# Use descriptive activity names to name the activities in the data set
colnames(activity_labels)<-c("activityID", "activity")
merged_data_with_activity_names<-merge(merged_data_mean_std,activity_labels,by="activityID")

#Appropriately labels the data set
colnames(merged_data_with_activity_names)<-gsub("Acc","acceleration",colnames(merged_data_with_activity_names))
colnames(merged_data_with_activity_names)<-gsub("Gyro","gyroscope",colnames(merged_data_with_activity_names))
colnames(merged_data_with_activity_names)<-gsub("Mag","magnitude",colnames(merged_data_with_activity_names))

# Create a second independent tidy data set
tidy_dataset= ddply(merged_data_with_activity_names,.(subjectID,activityID,activity), numcolwise(mean))
write.table(tidy_dataset,file="tidy_dataset.txt",row.names=FALSE)