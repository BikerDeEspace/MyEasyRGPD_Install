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
}

# CREATE & START SERVICE
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
  #Frontend credentials
	--client-id)
		CLIENT_ID="$2"
		;;
	--client-secret)
		CLIENT_SECRET="$2"
		;;
	--backend-url)
		BACKEND_URL="$2"
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

########################
# VERIFICATION OPTIONS #
########################
#Organisation
if [ -z $ORGNAME -o ]; then
    echo 'Empty Org'
    exit 1
fi
#Proxy & Letsencrypt
if [ -z $VIRTUAL_HOST ]; then
    echo 'Empty Vhost'
    exit 1
fi
if [ -z $LETSENCRYPT_HOST ]; then
    echo 'Empty LetsHo'
    exit 1
fi
if [ -z $LETSENCRYPT_EMAIL ]; then
    echo 'Empty LetsEmail'
    exit 1
fi
#Client credentials (Only for Frontend)
if [ $frontend -eq 1 ]; then
  if [ -z $CLIENT_ID ]; then
      echo ''
      exit 1
  fi
  if [ -z $CLIENT_SECRET ]; then
      echo ''
      exit 1
  fi
  if [ -z $BACKEND_URL ]; then
      echo ''
      exit 1
  fi
fi 

####################
# PACKAGES INSTALL #
####################
echo "** INSTALL PACKAGES FOR $OS **"

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
	*)
		echo "System : $OS not supported."
    exit 1
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

#################
# PROXY INSTALL #
#################
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

  if ! [ -f "$APPDIR/docker-compose.yml" ]; then 
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

if [ $frontend -eq 1 ]; then
  readonly APPDIR="/usr/share/MyEasyRGPD/frontend/$ORGNAME"
  readonly FRONTEND_SERVICE_NAME="front.$ORGORGNAME.MyEasyRGPD.service"

  if ! [ -f "$APPDIR/docker-compose.yml" ]; then 
    readonly GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git"
    git clone $GIT_URL $APPDIR
  fi

  if ! [ install_service $APPDIR $FRONTEND_SERVICE_NAME ]; then
    echo "Fail to create service: $FRONTEND_SERVICE_NAME"
    exit 1
  fi
fi



