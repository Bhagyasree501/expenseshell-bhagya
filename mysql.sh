#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
FILE_NAME="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
echo "$FILE_NAMEz"
mkdir -p $LOGS_FOLDER | tee -a $FILE_NAME
echo "script started executing at: $(date)" &>>$FILE_NAME

USER=$(id -u)

CHECK_ROOT(){
    if [ $USER -ne 0 ]
    then
        echo -e "$R hey!you are not a root user.please try with root user access. $N" | tee -a $FILE_NAME
        exit 1
    else
        echo -e "$G hey! good that you are using root access $N" | tee -a $FILE_NAME
    fi
}
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R hey! looks like $2 failed.please check your shell script $N" | tee -a $FILE_NAME
        exit 1
    else
        echo -e "$G hey! looks like $2 has been successful. $N" | tee -a $FILE_NAME
    fi
}

CHECK_ROOT #I am calling CHECK_ROOT function

dnf install mysql-server -y
VALIDATE $? "mysql installation"

systemctl enable mysqld
VALIDATE #? "enabling mysql server"

systemctl start mysqld
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting password for mysql server"