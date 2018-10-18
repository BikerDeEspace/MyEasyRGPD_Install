#!/usr/bin/env bash

############################################
### INSTALL SCRIPT WITHOUT SOURCES FILE  ###
### - LINUX VERSION                      ###
############################################
APP_VERSION='master'

APP_DIRECTORY='/usr/share/MyEasyRGPD'
SCRIPT_DIRECTORY=$(cd `dirname $0` && pwd)

SYSTEM='N/A'
APP='N/A'

LIST_SYSTEM="ubuntu arch centos"
LIST_APP="backend frontend"

############################
### COMMAND LINE OPTIONS ###
############################

COMMAND_LINE_OPTIONS_HELP='
Command line options:
    -s  SYSTEM      Set the host system (ubuntu, arch, centos)
                      default: N/A
    -a  APP         App to install (backend, frontend)
                      default: N/A

    -h              Print this help menu
'

while getopts "s:a:h" opt; do
  case $opt in
    s)
      SYSTEM="$OPTARG" >&2
      ;;
    a)
      APP="$OPTARG" >&2
      ;;
    h)
      echo "$COMMAND_LINE_OPTIONS_HELP"
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "$COMMAND_LINE_OPTIONS_HELP"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

#####################
### VERIFICATIONS ###
#####################

## OPTION EXIST : TEST SYSTEM / APP / MODE
if ! [[ $LIST_SYSTEM =~ (^|[[:space:]])"$SYSTEM"($|[[:space:]]) ]] ; then
  echo "ERROR - Unknown OS: $SYSTEM"
  exit 1
fi
if ! [[ $LIST_APP =~ (^|[[:space:]])"$APP"($|[[:space:]]) ]] ; then
  echo "ERROR - Unknown APP: $APP"
  exit 1
fi
## TEST LINUX DISTRIBUTION
OS=$(sed -n -e '/PRETTY_NAME/ s/^.*=\|"\| .*//gp' /etc/os-release | tr '[:upper:]' '[:lower:]')
if ! [[ $SYSTEM =~ (^|[[:space:]])"$OS"($|[[:space:]]) ]] ; then
  echo "No match system : $SYSTEM"
  exit 1
fi 

#################
#### INSTALL ####
#################
echo "*** INSTALL APPLICATION ***"
echo "- SYSTEM: $SYSTEM"
echo "- APP: $APP"

####################
# INSTALL PACKAGES #
####################
PACKAGES_SCRIPT=""

case $SYSTEM in
  'ubuntu')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/install/packages/ubuntu.sh"
    ;;
  'arch')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/install/packages/archlinux.sh"
    ;;
  'centos')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/install/packages/centos.sh"
    ;;
esac

if [ ! -f $PACKAGES_SCRIPT ]; then
  echo "Package uninstall script not found!"
  echo "Please Check : $PACKAGES_SCRIPT"
  exit 1
fi

#EXEC
if ! bash $PACKAGES_SCRIPT ; then
  echo "Package install fail"
  exit 1
fi

###########################
# PREPARE INSTALL SERVICE #
###########################
GIT_URL=""
SERVICE_NAME=""
SERVICE_SCRIPT="$SCRIPT_DIRECTORY/install/install-service.sh"
if [ ! -f $SERVICE_SCRIPT ]; then
  echo "Service install script not found!"
  echo "Please Check : $SERVICE_SCRIPT"
  exit 1
fi

case $APP in
  'backend')
    APP_DIRECTORY="$APP_DIRECTORY/backend"
    SERVICE_NAME="BackEasyRGPD.service"
    GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git"
    ;;
  'frontend')
    APP_DIRECTORY="$APP_DIRECTORY/frontend"
    SERVICE_NAME="FrontEasyRGPD.service"
    GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git"
    ;;
esac

git clone $GIT_URL -b $APP_VERSION $APP_DIRECTORY

################################
# CLIENT CRENDETIAL (FRONTEND) #
################################
if [ $APP -eq "frontend" ]; then
  #GET CRENDENTIALS
  read -p "Client id : " CLIENT_ID
  read -p "Client secret : " CLIENT_SECRET
  read -p "Backend url : " BACKEND_URL
  #SET CREDENTIALS 
  sed -i 's,<CLIENT_ID>,'"$CLIENT_ID"',g' $APP_DIRECTORY/docker-compose.yml
  sed -i 's,<CLIENT_SECRET>,'"$CLIENT_SECRET"',g' $APP_DIRECTORYY/docker-compose.yml
  sed -i 's,<BACKEND_URL>,'"$BACKEND_URL"',g' $APP_DIRECTORY/docker-compose.yml
fi

###########################
# ENV FILE (LETS_ENCRYPT) #
###########################
if [ ! -f $SCRIPT_DIRECTORY/.env ]; then
  echo "env file not found!"
  echo "Please Check : $SCRIPT_DIRECTORY/.env"
  exit 1
fi
cp $SCRIPT_DIRECTORY/.env $APP_DIRECTORY/.env

###################
# INSTALL SERVICE #
###################
if ! bash $SERVICE_SCRIPT $SCRIPT_DIRECTORY $APP_DIRECTORY $SERVICE_NAME ; then
  echo "Install service fail"
  exit 1
fi 

######################
# END INSTALL SCRIPT #
######################

echo "systemctl status $SERVICE_NAME"