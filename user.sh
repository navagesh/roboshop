#!/bin/#!/usr/bin/env bash

ID=$(id -u )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP"   &>> $LOGFILE
VALIDATE(){
if [ $1 -ne 0 ]
  then
    echo -e "$2 .....$R FAILED $N"
    exit 1
  else
    echo -e "$2.....$G SUCCESS $N"

  fi
}
if [ $ID -ne 0 ]
then
  echo -e "$R ERROR:: please run this script with root access $N"
  exit 1
else
  echo "you are root user"
fi

dnf module disable nodejs -y  &>> $LOGFILE

VALIDATE $? "Disabling current nodejs"
dnf module enable nodejs:18 -y  &>> $LOGFILE
VALIDATE $? "enabling current nodejs"
dnf install nodejs -y  &>> $LOGFILE
VALIDATE $? "installing nodejs -18"
id roboshop
if [ $? -ne 0 ]
then
  useradd roboshop &>> $LOGFILE
  VALIDATE $? "creating roboshop user"
else
  echo -e "roboshop user already exist $Y SKIPPING $N"

fi
mkdir -p /app  &>> $LOGFILE
VALIDATE $? "creating appdirectry"
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "downloading user application"

cd /app
unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping users"
npm install  &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user files"
systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "catalogue daemon reload"
systemctl enable user  &>> $LOGFILE
VALIDATE $? "enable  "
systemctl start user  &>> $LOGFILE
VALIDATE $? "start user "
cp /home/ec2-user/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
VALIDATE $? "copying mongodb repo "
dnf install mongodb-org-shell -y  &>> $LOGFILE
VALIDATE $? "installing mongodb client "

mongo --host mongodb.navagesh.store </app/schema/user.js  &>> $LOGFILE

VALIDATE $? "loading user data into mongodb "
