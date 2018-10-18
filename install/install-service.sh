#!/usr/bin/env bash

#################################
### INSTALL PRODUCTION        ###
### - LINUX VERSION           ###
#################################

## ARGUMENTS
# $1 - DIRECTORY
# $2 - SERVICE_FILE_NAME
# $3 - HOSTNAME

# VERIFICATIONS
## ARGUMENTS NUMBER
if ! [ $# -eq 3 ] ; then
    echo 'Arguments missing (3 Needed)'
    echo ' - MAIN_DIRECTORY (Service file example location)'
    echo ' - APP_DIRECTORY'
    echo ' - SERVICE_FILE_NAME'
    exit 1
fi
MAIN_DIRECTORY=$1
APP_DIRECTORY=$2
SERVICE_FILE_NAME=$3

################
# SCRIPT BEGIN #
################
echo "** Install Service $SERVICE_FILE_NAME **"

## CHECK IF SERVICE FILE EXIST
if ! [[ -f $MAIN_DIRECTORY/EasyRGPD.service ]] ; then
    echo 'Service file not found! Please check :'
    echo " - $MAIN_DIRECTORY/EasyRGPD.service"
    exit 1
fi

# SERVICE
# Create a clean copy of the service file
cp $MAIN_DIRECTORY/EasyRGPD.service $MAIN_DIRECTORY/$SERVICE_FILE_NAME
sed -i 's,APP_DIRECTORY,'"$APP_DIRECTORY"',g' $MAIN_DIRECTORY/$SERVICE_FILE_NAME

# Move the new service file in "/etc/systemd/system/" directory
mv $MAIN_DIRECTORY/$SERVICE_FILE_NAME  /etc/systemd/system/$SERVICE_FILE_NAME

## Enable the service at startup
systemctl enable $SERVICE_FILE_NAME
## Reload the deamon
systemctl daemon-reload
# Start the service 
systemctl start $SERVICE_FILE_NAME


## WAIT FOR THE APPLICATION
#while [ ! $(curl --output /dev/null --silent --head http://localhost) ] ; do
#    echo 'Loading application. Please Wait'
#    #SHOW LOGS
#    echo 'Logs:'
#    journalctl --unit=$SERVICE_FILE_NAME | tail -n 2
#
#    #TEST IF APP NOT FAIL
#    if $(systemctl is-failed --quiet $SERVICE_FILE_NAME); then
#        echo 'ERROR - Unknown'
#        journalctl --unit=$SERVICE_FILE_NAME | tail -n 2
#        exit 1
#    fi
#
#    sleep 10
#done

#APPLICATION READY
#echo "Application available on:" 
#echo "-> URL: http://$HOSTNAME"