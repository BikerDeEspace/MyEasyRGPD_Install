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

#INIT VAR
RM_VOLUMES=0
RM_IMAGES=0
ORGNAME=""
APPLICATION=""

#FUNCTIONS
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
	echo "  -l, --list"
	echo "      List of installed application."
	echo
	echo "  -o, --org"
	echo "      Mandatory option"
	echo
	echo "  -a, --application" 
	echo "      Mandatory option"
	echo "      Values : back, front"
	echo
}
# APP LIST
list() {
	BACKDIR="/usr/share/MyEasyRGPD/backend"
	FRONTDIR="/usr/share/MyEasyRGPD/frontend"
	if [ -d $BACKDIR ]; then
		echo "Backend :"
		ls $BACKDIR -l | awk '{print $NF}'
	fi
	if [ -d $FRONTDIR ]; then 
		echo "Frontend :"
		ls $FRONTDIR -l | awk '{print $NF}'
	fi
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

#SCRIPT OPTIONS
while [ "$#" -gt 0 ]
do
	case "$1" in
  #Help
	-h|--help)
		usage
		exit 0
		;;
	-l|--list)
		list
		exit 0
		;;
  #Organisation 
	-o|--org)
		ORGNAME=$(echo "$2" | tr '[:upper:]' '[:lower:]')
		;;
  #Application
	-a|--application)
		APPLICATION=$(echo "$2" | tr '[:upper:]' '[:lower:]')
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

#OPTIONS VERIFICATIONS
if [ "$ORGNAME" = "" ]; then
		echo 'Mandatory option missing or empty [-o, --org]'
		exit 1
elif [ "$ORGNAME" = "default" ]; then
	#ASK FOR CONFIRM
	read -r -p "Remove the default app? [y/N] " response
	response=${response,,}
	if ! [[ "$response" =~ ^(yes|y)$ ]]; then
		exit 1
	fi
fi

if [ "$APPLICATION" = "" ]; then
		echo 'Mandatory option missing or empty [-a, --application]'
		exit 1
fi

#SET ENV
readonly MAIN_DIR="/usr/share/MyEasyRGPD"
case $APPLICATION in
  'back') 
		readonly APP_SERVICE_NAME="back.$ORGNAME.MyEasyRGPD.service"
		readonly APP_DIR="$MAIN_DIR/backend/$ORGNAME"
	;;
  'front')
		readonly APP_SERVICE_NAME="front.$ORGNAME.MyEasyRGPD.service"
		readonly APP_DIR="$MAIN_DIR/frontend/$ORGNAME"
	;;	
  *)
  echo "Application : Unknown $APPLICATION"
  exit 1
  ;;
esac

#ENV RECAP
echo
echo "ENVIRONMENT VARIABLES RECAP"
echo "  - HOST SYSTEM : $OS"
echo "  - APP DIR : $APP_DIR"
echo "  - APP SERVICE NAME : $APP_SERVICE_NAME"

#ASK FOR CONFIRM BEFORE CONTINUE
echo
echo " WARNING This will remove :"
echo "	- Docker volumes (For selected application)"
echo " 	- Docker images (For selected application)"
read -r -p "Are you sure? [y/N] " response
response=${response,,}
if ! [[ "$response" =~ ^(yes|y)$ ]]; then
  exit 1
fi

#SERVICE UNINSTALL
if ! uninstall_service $APP_SERVICE_NAME ; then
	echo "Uninstall service failed : $APP_SERVICE_NAME"
	exit 1
fi

#REMOVE DOCKER VOLUMES / IMAGES
docker volume rm $(docker volume ls | grep $ORGNAME)
docker image rm -f $(docker image ls | grep $ORGNAME)

#APP FOLDER REMOVE
echo "** Remove folder $APP_DIR **"
rm -rf "$APP_DIR"

#TODO ONLY IF NO OTHER APP INSTALLED 
if [ ! "$(ls -A $MAIN_DIR/backend)" ] && [ ! "$(ls -A $MAIN_DIR/frontend)" ]; then
  echo "No other MyEasyRGPD ..."
	echo "	- Removing Proxy & Package"
	
	#MAIN APP FOLDER REMOVE /usr/share/MyEasyRGPD
	rm -rf $MAIN_DIR

	#REMOVE PROXY
	echo "** UNINSTALL PROXY **"

	readonly PROXY_SERVICE_NAME="MyEasyRGPD_Proxy.service"
	readonly PROXY_DIR="/srv/www/nginx-proxy"

	##REMOVE PROXY SERVICE 
	if ! uninstall_service $PROXY_SERVICE_NAME ; then
		echo "Uninstall service failed : $PROXY_SERVICE_NAME"
		exit 1
	fi

	##REMOVE PROXY DIRECTORY  
	rm -rf $PROXY_DIR

	#REMOVE CONTAINER / VOLUME / IMAGE
	docker container rm $(docker container ls -aq)
	docker volume rm $(docker volume ls | grep $ORGNAME)
	docker image rm $(docker image ls -q)
	docker network rm $(docker network ls -q)

	#PACKAGES UNINSTALL (Docker ...)
	echo "** UNINSTALL PACKAGES FOR $OS **"
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
	if [ ! -f $PACKDIR ]; then
		echo "Package uninstall script not found!"
		echo "Please Check : $PACKDIR"
		exit 1
	fi
	if ! bash $PACKDIR ; then
		echo "Package uninstall fail"
		exit 1
	fi
fi

#END UNISTALL SCRIPT