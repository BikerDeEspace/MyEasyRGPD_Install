#!/usr/bin/env bash

##############################
### UNINSTALL - MyEasyRGPD ###
### - LINUX VERSION        ###
##############################

# Host system
readonly OS=$(sed -n -e '/PRETTY_NAME/ s/^.*=\|"\| .*//gp' /etc/os-release | tr '[:upper:]' '[:lower:]')
# File name
readonly PROGNAME=$(basename $0)
# File name, without the extension
readonly PROGBASENAME=${PROGNAME%.*}
# File directory
readonly PROGDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Arguments
readonly ARGS="$@"
# Arguments number
readonly ARGNUM="$#"

#############
# FUNCTIONS #
#############

# SCRIPT HELP MENU
usage() {
	echo "Script description"
	echo
	echo "Usage: $PROGNAME [options]..."
	echo
	echo "Options:"
	echo
	echo "  -h, --help"
	echo "      This help text."
	echo
  echo "  -o, --org"
  echo "      Mandatory option"
	echo
	echo "  -a, --application" 
  echo "      Mandatory option"
  echo "      Values : back, backend, front, frontend"
  echo
	echo " 	-v, --volume"
	echo "			Optional - Remove Docker volumes for the app"
	echo 
	echo " 	-i, --image"
	echo "			Optional - Remove Docker images for the app"
	echo
}

# UNISTALL SERVICE
uninstall_service(){
	echo "** Remove Service $1 **"
	#CHECK SERVICE FILE
	if ! [ -f /etc/systemd/system/$1 ]; then
		echo "Service file not found! $1"
		exit 1
	fi
	# STOP SERVICE IF ACTIVE
	if $(systemctl is-active --quiet $1); then 
			systemctl stop $1
	fi
	## DISABLE SERVICE AT STARTUP
	systemctl disable $1
	## REMOVE SERVICE
	rm /etc/systemd/system/$1
}

##################
# SCRIPT OPTIONS #
##################
while [ "$#" -gt 0 ]
do
	case "$1" in
  #Help
	-h|--help)
		usage
		exit 0
		;;
  #Organisation 
	-o|--org)
		ORGNAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
		;;
  #Application
	-a|--application)
		APPLICATION=$(echo "$1" | tr '[:upper:]' '[:lower:]')
		;;
	#Docker
	-v|--volume)
		RM_VOLUMES=1
		;;
	-i|--image)
		RM_IMAGES=1
		;;
  #Others 
	--)
		break
		;;
	-*)
		echo "Invalid option '$1'. Use --help to see the valid options" >&2
		exit 1
		;;
	#Option argument, continue
	*)	;;
	esac
	shift
done

#################
# VERIFICATIONS #
#################
if [ -z $ORGNAME ] || [ $ORGNAME == "" ]; then
		echo 'Mandatory option missing or empty [-o, --org]'
		exit 1
fi
if [ -z $APPLICATION ] || [ $APPLICATION == "" ]; then
		echo 'Mandatory option missing or empty [-a, --application]'
		exit 1
fi

# SET VAR
case $APPLICATION in
  'back'|'backend') 
		APP_SERVICE_NAME="back.$ORGNAME.MyEasyRGPD.service"
		APP_DIR="/usr/share/MyeasyRGPD/backend/$ORGNAME"
	;;
  'front'|'frontend')
		APP_SERVICE_NAME="front.$ORGNAME.MyEasyRGPD.service"
		APP_DIR="/usr/share/MyeasyRGPD/backend/$ORGNAME"
	;;	
  *)
  echo "Application : Unknown $APPLICATION"
  exit 1
  ;;
esac

##############################
# SERVICE UNINSTALL & REMOVE #
##############################
if ! uninstall_service $APP_SERVICE_NAME ; then
	echo "Uninstall service failed : $APP_SERVICE_NAME"
	exit 1
fi

######################
#  REMOVE DOCKER ELT #
######################
# VOLUMES
if [ -z $RM_VOLUMES ] && [ $RM_VOLUMES -eq 1 ]; then
	echo "** Remove volumes **"
	docker volume rm $(docker volume ls | grep \'$ORGNAME\')
fi
# IMAGES
if [ -z $RM_IMAGES ] && [ $RM_IMAGES -eq 1 ]; then
	echo "** Remove images **"
	docker image rm -f $(docker image ls | grep \'$ORGNAME\')
fi

#####################
# APP FOLDER REMOVE #
#####################
rm -rf $APP_DIR


exit 0
#if last app

################
# REMOVE PROXY #
################

#Todo

######################
# PACKAGES UNINSTALL #
######################
echo "** INSTALL PACKAGES FOR $OS **"
PACKDIR=""
case $OS in
  'ubuntu')
    PACKDIR="$PROGDIR/uninstall/packages/ubuntu.sh"
    ;;
  'arch')
    PACKDIR="$PROGDIR/uninstall/packages/archlinux.sh"
    ;;
  'centos')
    PACKDIR="$PROGDIR/uninstall/packages/centos.sh"
    ;;
	*)
		echo "System : $OS not supported."
    exit 1
		;;
esac
# CHECK IF FILE EXIST
if [ ! -f $PACKDIR ]; then
  echo "Package uninstall script not found!"
  echo "Please Check : $PACKDIR"
  exit 1
fi
# INSTALL PACKAGES
if ! bash $PACKDIR ; then
  echo "Package uninstall fail"
  exit 1
fi

