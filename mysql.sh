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
     echo -e " $2  was $R failed $N "|tee -a "$LOG_FILE"
    else
     echo -e " $2  was $G Success $N"|tee -a "$LOG_FILE"
    fi
}
CHECK_ROOT

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "MySQL server"

systemctl enable mysqld
VALIDATE $? "enabled MySQL server"

systemctl start mysqld
VALIDATE $? "started MySQL server"

mysql -h mysql.jagathlearn.art -u root -pExpenseApp@1 -e 'show databases;'
 if [ $? -ne 0 ]
 then
  echo "MySQL root password is not set up.. setting it now" &>> $LOG_FILE
  mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "setting up root password"
 else
   echo -e "MySQL root password $Y SKIPPING $N"|tee -a "$LOG_FILE"  
  fi 





