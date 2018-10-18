#!/usr/bin/env bash

##############################################
### UNINSTALL SCRIPT WITHOUT SOURCES FILE  ###
### - LINUX VERSION                        ###
##############################################
APP_DIRECTORY='/usr/share/MyEasyRGPD'
SCRIPT_DIRECTORY=$(cd `dirname $0` && pwd)

SYSTEM='N/A'
APP='N/A'

LIST_SYSTEM="ubuntu arch centos"
LIST_APP="backend frontend"

RM_VOL=0
RM_IMG=0

COMMAND_LINE_OPTIONS_HELP='
Command line options:
    -s  SYSTEM      Set the host system (ubuntu, arch, centos)
                      default: N/A
    -a  APP         App to install (backend, frontend)
                      default: N/A

    -v  VOLUME      Remove all volumes
    -i  IMAGE       Remove all images

    -h              Print this help menu
'

# COMMAND LINE OPTIONS
while getopts "s:a:vih" opt; do
  case $opt in
    s)
      SYSTEM="$OPTARG" >&2
      ;;
    a)
      APP="$OPTARG" >&2
      ;;
    v)
      RM_VOL=1
      ;;
    i)
      RM_IMG=1
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

#######################
#### VERIFICATIONS ####
#######################

## TEST IF CORRECT OPTIONS
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

## TEST IF APPLICATION FOLDER EXIST
if [ ! -d $APP_DIRECTORY ] ; then
  echo "Application folder not found at $APP_DIRECTORY"
  exit 0
fi

###################
#### UNINSTALL ####
###################
echo "*** UNINSTALL APPLICATION ***"
echo "-SYSTEM: $SYSTEM"
echo "-APP: $APP"

#################################
# UNINSTALL APPLICATION SERVICE #
#################################
SERVICE_SCRIPT="$SCRIPT_DIRECTORY/uninstall/uninstall-service.sh"
if [ ! -f $SERVICE_SCRIPT ]; then
  echo "Service install script not found!"
  echo "Please Check : $SERVICE_SCRIPT"
  exit 1
fi

case $APP in
  'backend')
    bash $SERVICE_SCRIPT "BackEasyRGPD.service"
    rm -rf "$APP_DIRECTORY/backend"
    ;;
  'frontend')
    bash $SERVICE_SCRIPT "FrontEasyRGPD.service"
    rm -rf "$APP_DIRECTORY/frontend"
    ;;
esac

##########################
# REMOVE DOCKER ELEMENTS #
##########################
## Remove images
if [ $RM_IMG -eq 1 ] ; then
  echo '** REMOVE IMAGES **'
  docker image rm $(docker image ls -a -q)
fi
## Remove volumes 
if [ $RM_VOL -eq 1 ] ; then
  echo '** REMOVE VOLUMES **'
  docker volume rm $(docker volume ls -q)
fi
## Remove networks
docker network rm $(docker network ls -q)
## Remove containers
docker container rm $(docker container ls -a -q)

###################
# REMOVE PACKAGES #
###################
PACKAGES_SCRIPT=""

case $SYSTEM in
  'ubuntu')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/uninstall/packages/ubuntu.sh"
    ;;
  'arch')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/uninstall/packages/archlinux.sh"
    ;;
  'centos')
    PACKAGES_SCRIPT="$SCRIPT_DIRECTORY/uninstall/packages/centos.sh"
    ;;
esac

if [ ! -f $PACKAGES_SCRIPT ]; then
  echo "Package uninstall script not found!"
  echo "Please Check : $PACKAGES_SCRIPT"
  exit 1
fi

# Remove package script execution
if ! bash $PACKAGES_SCRIPT ; then
  echo "Package uninstall fail"
  exit 1
fi