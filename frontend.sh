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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enabled nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /usr/share/nginx/html

rm -rf /usr/share/nginx/html/*

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting frontend application code"

cp 
