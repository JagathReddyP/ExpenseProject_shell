#!/bin/bash

# >> --> it wont override previous data it appends the existing data ex: &>> , ls -l 2>> output.txt
# tee --> wite logs to multiple destinations


LOGS_FOLDER="/var/log/expense"
#SCRIPT_NAME=$(echo "$0"|cut -d "." -f1)  
SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p "$LOGS_FOLDER"

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)

CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]
    then
     echo -e " you are not a root user, $R switch to root user $N "|tee -a "$LOG_FILE"
     exit 1
    fi
}

VALIDATE() {
    if [ "$1" -ne 0 ]
    then
     echo -e "$2 was $R failed $N "|tee -a "$LOG_FILE"
    else
     echo -e "$2 was $G Success $N"|tee -a "$LOG_FILE"
    fi
}
CHECK_ROOT

echo "script started executing at : $(date)"|tee -a "$LOG_FILE"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
echo -e "expense user was not created..$G creating $N"
useradd expense &>>$LOG_FILE
VALIDATE $? "Creating expense user"
else
echo -e "expense user was already exist $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app folder" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app
rm -rf /app/* #remove if any existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"

npm install &>>$LOG_FILE


