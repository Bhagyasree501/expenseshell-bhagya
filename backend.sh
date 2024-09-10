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
echo "$FILE_NAME"
mkdir -p $LOGS_FOLDER &>> $FILE_NAME
echo "script started executing at: $(date)" | tee -a $FILE_NAME

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

#dnf module disable nodejs -y &>> $FILE_NAME
#VALIDATE $?  "disabling NodeJs"

#dnf module enable nodejs:20 -y &>> $FILE_NAME
#VALIDATE $? "enabling version 20 of NodeJs"

#dnf install nodejs -y &>> $FILE_NAME
#VALIDATE $? "installing NodeJs"

#useradd expense &>> $FILE_NAME
#VALIDATE $? "adding a user with username expense"