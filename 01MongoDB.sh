#!/bin/bash
ID=$(id -u)
timestamp=$(date +%Y%m%d_%H%M%S)
logfile="mongo_backup_$timestamp.log"

echo "Starting MongoDB backup at $(date)" | tee -a "$logfile"
echo "Script executed by user: $(whoami)" | tee -a "$logfile"

if [ "$ID" -ne 0 ]; then
  echo "This script must be run as root. Exiting." | tee -a "$logfile"
  exit 1
fi

validate() {
    if [ "$?" -ne 0 ]; then
        echo -e "Error: $2 .... $R Failed" 
    else
        echo -e "Success: $1 .... $G Passed"
    fi
}

if [ $ID -ne 0 ]; then
    echo "This script must be run as root. Exiting." | tee -a "$logfile"
    exit 1
else
    echo "User is root. Proceeding..." | tee -a "$logfile"
fi

cp Mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile
validate $1 "Copying MongoDB repo file" 

dnf install mongodb-org -y &>> $logfile
validate $1 "Installing MongoDB"

systemctl enable mongod &>> $logfile
validate $1 "Enabling MongoDB service"

systemctl start mongod &>> $logfile
validate $1 "Starting MongoDB service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $logfile
validate $1 "Modifying MongoDB bindIp"

systemctl restart mongod &>> $logfile
validate $1 "Restarting MongoDB service"





