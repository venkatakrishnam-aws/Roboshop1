#!/bin/bash

id=$(id -u)
R = '\e[31m'
G = '\e[32m'
Y = '\e[33m'
N = '\e[0m'

timestamp=$(date +%Y%m%d_%H%M%S)
logfile="catalogue_backup_$timestamp.log"
echo "Starting Catalogue setup at $(date)" | tee -a "$logfile"

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "Error: $2 ... $R Failed cant proceed"
        exit 1                               
    else
        echo -e "Success: $1 .... $G Passed"
    fi
}
    
if [ $id -ne 0 ]; then
  echo "This script must be run as root. Exiting."
  exit 1
  else echo "User is root. Proceeding..."
fi

dnf module disable nodejs -y &>> $logfile
validate $1 "Disabling NodeJS module" &>> $logfile

dnf module enable nodejs:18 -y &>> $logfile
validate $1 "Enabling NodeJS 18 module" &>> $logfile

dnf install nodejs -y &>> $logfile
validate $1 "Installing NodeJS" &>> $logfile

dnf install nodejs -y &>> $logfile
validate $1 "Installing NodeJS 18" &>> $logfile

useradd roboshop &>> $logfile
validate $1 "Adding roboshop user" &>> $logfile

mkdir /app &>> $logfile
validate $1 "Creating /app directory" &>> $logfile

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $logfile
validate $1 "Downloading catalogue code" &>> $logfile

cd/app &>> $logfile
validate $1 "Changing directory to /app" &>> $logfile

unzip /tmp/catalogue.zip &>> $logfile
validate $1 "Extracting catalogue code" &>> $logfile

npm install &>> $logfile
validate $1 "Installing NodeJS dependencies" &>> $logfile

cp catalogue.service /etc/systemd/system/catalogue.service &>> $logfile
validate $1 "Copying catalogue systemd file" &>> $logfile

systemctl daemon-reload &>> $logfile
validate $1 "Reloading systemd" &>> $logfile

systemctl enable catalogue &>> $logfile
validate $1 "Enabling catalogue service" &>> $logfile

systemctl start catalogue &>> $logfile
validate $1 "Starting catalogue service" &>> $logfile

echo -e "\e[32mCatalogue setup completed successfully at $(date) \e[0m" | tee -a "$logfile"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile
validate $1 "Copying MongoDB repo file" &>> $logfile

dnf install mongodb-org-shell -y &>> $logfile
validate $1 "Installing MongoDB client" &>> $logfile

mongo --host mongodb.vk98.space </app/schema/catalogue.js &>> $logfile
validate $1 "Loading catalogue schema" &>> $logfile

echo -e "\e[32mCatalogue schema loaded successfully at $(date) \e[0m" | tee -a "$logfile"

# End of script


