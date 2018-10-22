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

case $APP in
  'backend')
    GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git"
    ;;
  'frontend')
    GIT_URL="https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git"
    ;;
esac



readonly VIRTUAL_HOST=
readonly LETSENCRYPT_HOST=
readonly LETSENCRYPT_EMAIL=
readonly HOST_PORT=

readonly CLIENT_ID=
readonly CLIENT_SECRET=
readonly BACKEND_URL=

