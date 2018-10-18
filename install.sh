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

# Install package script execution
if ! bash $PACKAGES_SCRIPT ; then
  echo "Package install fail"
  exit 1
fi

###################
# INSTALL SERVICE #
###################
SERVICE_SCRIPT="$SCRIPT_DIRECTORY/install/install-service.sh"
if [ ! -f $SERVICE_SCRIPT ]; then
  echo "Service install script not found!"
  echo "Please Check : $SERVICE_SCRIPT"
  exit 1
fi

case $APP in
  'backend')
    APP_DIRECTORY="$APP_DIRECTORY/backend"
    git clone https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git -b $APP_VERSION $APP_DIRECTORY

    bash $SERVICE_SCRIPT $SCRIPT_DIRECTORY $APP_DIRECTORY "BackEasyRGPD.service"
    ;;
  'frontend')
    APP_DIRECTORY="$APP_DIRECTORY/frontend"
    git clone https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git -b $APP_VERSION $APP_DIRECTORY

    bash $SERVICE_SCRIPT $SCRIPT_DIRECTORY $APP_DIRECTORY "FrontEasyRGPD.service"
    ;;
esac