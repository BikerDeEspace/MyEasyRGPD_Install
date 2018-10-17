#!/usr/bin/env bash

##############################################
### UNINSTALL SCRIPT WITHOUT SOURCES FILE  ###
### - LINUX VERSION                        ###
##############################################
APP_PATH='/usr/share/pialab'

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
if [ ! -d $APP_PATH ] ; then
  echo "Application folder not found at $APP_PATH"
  exit 0
fi

###################
#### UNINSTALL ####
###################

echo "*** UNINSTALL APPLICATION ***"
echo "-SYSTEM: $SYSTEM"
echo "-APP: $APP"


case $APP in
  ## BACKEND
  'backend')
    cd $APP_PATH && bash setup/install/uninstall-prod.sh "BackEasyRGPD.service"
    ;;
  ## FRONTEND
  'frontend')
    cd $APP_PATH && bash setup/uninstall/uninstall-prod.sh "FrontEasyRGPD.service"
    ;;
esac

# DOCKER REMOVE
## REMOVE ALL (CONTAINER, NETWORKS, IMAGES, BUILD CACHE)
if [ $RM_IMG -eq 1 ] ; then
  echo '** REMOVE IMAGES **'
  docker image rm $(docker image ls -a -q)
fi
if [ $RM_VOL -eq 1 ] ; then
  echo '** REMOVE VOLUMES **'
  docker volume rm $(docker volume ls -q)
fi
docker network rm $(docker network ls -q)
docker container rm $(docker container ls -a -q)

echo '** REMOVE PACKAGES **'
# UNINSTALL NEEDED
case $SYSTEM in
  ## UBUNTU
  'ubuntu')
    bash "$APP_PATH/setup/uninstall/packages/apt.sh"
    ;;
  ## UBUNTU
  'arch')
    bash "$APP_PATH/setup/uninstall/packages/pacman.sh"
    ;;
  ## CENTOS
  'centos')
    bash "$APP_PATH/setup/uninstall/packages/yum.sh"
    ;;
esac

