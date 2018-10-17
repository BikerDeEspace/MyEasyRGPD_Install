#!/usr/bin/env bash

## ARGUMENTS
# $1 - SERVICE_FILE_NAME

# VERIFICATIONS
## ARGUMENTS NUMBER
if ! [ $# -eq 1 ] ; then
    echo 'Arguments missing (Service name needed)'
    exit 1
fi
SERVICE_FILE_NAME=$1

################
# SCRIPT BEGIN #
################

# STOP SERVICE IF ACTIVE
if $(systemctl is-active --quiet $SERVICE_FILE_NAME); then 
    systemctl stop $SERVICE_FILE_NAME
fi

# REMOVE PIALAB SERVICE FROM STARTUP
## DISABLE SERVICE AT STARTUP
systemctl disable $SERVICE_FILE_NAME
## REMOVE SERVICE
rm /etc/systemd/system/$SERVICE_FILE_NAME