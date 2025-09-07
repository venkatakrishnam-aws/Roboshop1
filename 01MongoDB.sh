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

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate "Copying MongoDB repo file" "$logfile"


