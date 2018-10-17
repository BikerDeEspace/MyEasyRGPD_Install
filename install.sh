#!/usr/bin/env bash

############################################
### INSTALL SCRIPT WITHOUT SOURCES FILE  ###
### - LINUX VERSION                      ###
############################################
APP_VERSION='change-structure'
APP_PATH='/usr/share/myeasyrgpd'

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

# INSTALL PACKAGE & GET APPLICATION
echo "** INSTALL PACKAGES **"
case $SYSTEM in
  ## UBUNTU
  'ubuntu')
    if ! bash "./install/packages/apt.sh" ; then 
      echo "Echec de l'installation des packages!"
      exit 1
    fi
    ;;
  ## ARCH
  'arch')
    if ! bash "/install/packages/pacman.sh" ; then 
      echo "Echec de l'installation des packages!"
      exit 1
    fi
    ;;
  ## CENT OS
  'centos')
    if ! bash "./install/packages/yum.sh" ; then
      echo "Echec de l'installation des packages!"
      exit 1
    fi
    ;;
esac

# INSTALL APPLICATION
echo "** INSTALL SELECTED APP **"
case $APP in
  ## BACKEND
  'backend')
    git clone https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git -b "$APP_VERSION" "$APP_PATH"
    ;;
  ## FRONTEND
  'frontend')
    git clone https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git -b "$APP_VERSION" "$APP_PATH"
    ;;
esac