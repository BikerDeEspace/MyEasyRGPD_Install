#!/usr/bin/env bash

############################
### INSTALL - MyEasyRGPD ###
### - LINUX VERSION      ###
############################

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
}
install_service(){
  if ! [ -f /etc/systemd/system/$SERVICE_FILE_NAME ]; then
    echo "** Install Service $2 **"
    if ! [[ -f $PROGDIR/install/example.service ]] ; then
        echo 'Service file not found! Please check :'
        echo " - $PROGDIR/install/example.service"
        exit 1
    fi

    # Create a clean copy of the service file
    cp $PROGDIR/example.service $PROGDIR/$2
    sed -i 's,APP_DIRECTORY,'"$1"',g' $PROGDIR/$2
    # Move the new service file in "/etc/systemd/system/" directory
    mv $PROGDIR/$2  /etc/systemd/system/$2
    ## Enable the service at startup
    systemctl enable $2
    ## Reload the deamon
    systemctl daemon-reload
  fi
  echo "** Start Service $2 **"
  systemctl start $2
}

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
		ORGNAME="$2"
		;;
  #Application
	-b|--backend)
		backend=1
		;;
	-f|--frontend)
		frontend=1
		;;
  #Proxy & Letsencrypt
	--vhost)
		VIRTUAL_HOST="$2"
		;;
	--encrypt-host)
		LETSENCRYPT_HOST="$2"
		;;
	--encrypt-mail)
		LETSENCRYPT_EMAIL="$2"
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


############
# PACKAGES #
############
PACKDIR=""

case $OS in
  'ubuntu')
    PACKDIR="$PROGDIR/install/packages/ubuntu.sh"
    ;;
  'arch')
    PACKDIR="$PROGDIR/install/packages/archlinux.sh"
    ;;
  'centos')
    PACKDIR="$PROGDIR/install/packages/centos.sh"
    ;;
esac
# CHECK IF FILE EXIST
if [ ! -f $PACKDIR ]; then
  echo "Package install script not found!"
  echo "Please Check : $PACKDIR"
  exit 1
fi
# INSTALL PACKAGES
if ! bash $PACKDIR ; then
  echo "Package install fail"
  exit 1
fi

#########
# PROXY #
#########
readonly PROXY_GIT=https://github.com/BikerDeEspace/nginx-proxy.git
readonly PROXY_SERVICE_NAME="MyEasyRGPD_Proxy.service"
readonly PROXY_DIR="/srv/www/nginx-proxy"
readonly PROXY_NETWORK="nginx-proxy"

#GET SOURCES IF NOT EXIST
if ! [ -f "$PROXY_DIR/docker-compose.yml" ]; then
  #GET PROXY
  git clone $PROXY_GIT $PROXY_DIR
  #CREATE NETWORK
  docker network create --driver bridge $PROXY_NETWORK || true
fi
# INSTALL and|or START SERVICE
if ! [ install_service $PROXY_DIR $SERVICE_FILE_NAME ]; then
  echo "Fail to create service: $SERVICE_FILE_NAME"
  exit 1
fi

########################
# INSTALL SELECTED APP #
########################


# BACKEND

## TODO
# Post install

if [ $backend - eq 1 ]; then 
  readonly APPDIR="/usr/share/MyEasyRGPD/backend/$ORGNAME"
  readonly BACKEND_SERVICE_NAME="back.$ORGORGNAME.MyEasyRGPD.service"

  if ! [ -d $APPDIR ]; then 
    readonly GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git"
    git clone $GIT_URL $APPDIR
  fi

  if ! [ install_service $APPDIR $BACKEND_SERVICE_NAME ]; then
    echo "Fail to create service: $BACKEND_SERVICE_NAME"
    exit 1
  fi
fi 


# FRONTEND

## TODO
#readonly CLIENT_ID=
#readonly CLIENT_SECRET=
#readonly BACKEND_URL=

if [ $frontend -eq 1 ]; then
  readonly APPDIR="/usr/share/MyEasyRGPD/frontend/$ORGNAME"
  readonly FRONTEND_SERVICE_NAME="front.$ORGORGNAME.MyEasyRGPD.service"

  if ! [ -d $APPDIR ]; then 
    readonly GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git"
    git clone $GIT_URL $APPDIR
  fi

  if ! [ install_service $APPDIR $FRONTEND_SERVICE_NAME ]; then
    echo "Fail to create service: $FRONTEND_SERVICE_NAME"
    exit 1
  fi
fi



