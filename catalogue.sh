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

useradd roboshop &>> $LOGFILE
VALIDATE $? "creating roboshop user"

mkdir /app  &>> $LOGFILE
VALIDATE $? "creating appdirectry"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "downloading catalogue application"

cd /app
unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzipping catalogue"
npm install  &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copying catalogue files"
systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "catalogue daemon reload"
systemctl enable catalogue  &>> $LOGFILE
VALIDATE $? "enable catalogue "
systemctl start catalogue  &>> $LOGFILE
VALIDATE $? "start catalogue "
cp /home/centos/roboshop /mongo.repo/etc/yum.repos.d/mongo.repo  &>> $LOGFILE
VALIDATE $? "copying mongodb repo "
dnf install mongodb-org-shell -y  &>> $LOGFILE
VALIDATE $? "installing mongodb client "

mongo --host mongodb.navagesh.store </app/schema/catalogue.js  &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb "
