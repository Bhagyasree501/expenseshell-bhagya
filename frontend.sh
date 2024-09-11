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
mkdir -p $LOGS_FOLDER
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

dnf install nginx -y &>>$FILE_NAME
VALIDATE $? "installing Nginx"

systemctl enable nginx &>>$FILE_NAME
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$FILE_NAME
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading app we code in zip format"

cd /usr/share/nginx/html/
unzip /tmp/frontend.zip
VALIDATE $? "unzipping app web code into html dir"

cp /home/ec2-user/expenseshell-bhagya/expense.conf /etc/nginx/expense.conf

systemctl restart nginx &>>$FILE_NAME
VALIDATE $? "restarting nginx"