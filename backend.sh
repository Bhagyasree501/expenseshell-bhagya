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

dnf module disable nodejs -y &>> $FILE_NAME
VALIDATE $?  "disabling NodeJs"

dnf module enable nodejs:20 -y &>> $FILE_NAME
VALIDATE $? "enabling version 20 of NodeJs"

dnf install nodejs -y &>> $FILE_NAME
VALIDATE $? "installing NodeJs"

id expense &>> $FILE_NAME
if [ $? -ne 0 ]
then
    echo "hey! looks like exoense user does not exist. creating expense user" | tee -a $FILE_NAME
    useradd expense &>> $FILE_NAME
    VALIDATE $? "adding a user with username expense" | tee -a $FILE_NAME
else
    echo "hey! user already exists. nothing to do" | tee -a $FILE_NAME
fi

mkdir -p /app &>>$FILE_NAME
VALIDATE $? "creating /app directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$FILE_NAME
VALIDATE $? "downloading backend application code in zip file"

cd /app
rm -rf /app/* &>>$FILE_NAME
unzip /tmp/backend.zip &>>$FILE_NAME
VALIDATE $? "unzip the application code into /app folder"

npm install &>>$FILE_NAME
VALIDATE $? "downloading the dependencies"

cp /home/ec2-user/expenseshell-bhagya/backend.service /etc/systemd/system/backend.service

# We are trying to access the mysql-server on db server and execute backend.sql there; and generate schema there

dnf install mysql -y &>>$FILE_NAME
VALIDATE $? "installing mysql client on backendserver"

mysql -h 172.31.80.119 -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "loading schema"

# trying to start the service now
systemctl daemon-reload
VALIDATE $? "deamon reload"

systemctl restart backend
VALIDATE $? "restarting backend.service"

systemctl enable backend
VALIDATE $? "enabling backend.service"

# After the backend service is up and running we have 3 commands to check the status of service. They need to be verified on backend server

