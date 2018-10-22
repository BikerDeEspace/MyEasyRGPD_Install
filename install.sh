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
  echo "      <Help>"
	echo
	echo "  -b, --backend" 
  echo "      <Help>"
  echo
	echo "  -f, --frontend"
  echo "      <Help>"
  echo
	echo "  -v, --vhost"
  echo "      <Help>"
  echo
	echo "  -h, --encrypt-host"
  echo "      <Help>"
  echo
	echo "  -m, --encrypt-mail"
  echo "      <Help>"
  echo
	echo "  -i, --client-id)"
  echo "      <Help>"  
  echo
	echo "  -s, --client-secret"
  echo "      <Help>"   
  echo
	echo "  -u, --backend-url"
  echo "      <Help>"
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
		ORGNAME=$(echo "$2" | tr '[:upper:]' '[:lower:]')
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

### Organisation ###
if [ -z $ORGNAME ]; then
  echo 'Mandatory option missing [-o, --org]' | ERR=1
fi

### Proxy & Letsencrypt ###
if [ -z $VIRTUAL_HOST ]; then
  VIRTUAL_HOST="$ORGNAME.myeasyrgpd.lusis.lu"
  echo "VIRTUAL_HOST set by default : $VIRTUAL_HOST"
fi
if [ -z $LETSENCRYPT_HOST ]; then
  LETSENCRYPT_HOST=$VIRTUAL_HOST
  echo "LETSENCRYPT_HOST set by default : $LETSENCRYPT_HOST"
fi
if [ -z $LETSENCRYPT_EMAIL ]; then
  echo 'Mandatory option missing [--encrypt-mail]' | ERR=1
fi

### Client credentials (Only for Frontend) ###
if [ $frontend -eq 1 ]; then
  if [ -z $CLIENT_ID ]; then
      echo 'Mandatory option missing [-i, --client-id]' | ERR=1
  fi
  if [ -z $CLIENT_SECRET ]; then
      echo 'Mandatory option missing [-s, --client-secret]' | ERR=1
  fi
  if [ $backend -eq 1 ]; then
    BACKEND_URL="https://back.$VIRTUAL_HOST"
    echo "BACKEND_URL set by default : $BACKEND_URL"
  else
    BACKEND_URL="https://back.myeasyrgpd.lusis.lu"
    echo "BACKEND_URL set by default : $BACKEND_URL"
  fi
fi 

if [ $ERR -eq 1 ]; then
  echo "Options errors." 
  exit 1
fi

echo "** RECAP **"
echo "ORGNAME : $ORGNAME"
echo "VIRTUAL_HOST : $VIRTUAL_HOST"
echo "LETSENCRYPT_HOST : $LETSENCRYPT_HOST"
echo "LETSENCRYPT_EMAIL : $LETSENCRYPT_EMAIL"
if [ $frontend -eq 1 ]; then
  echo "CLIENT_ID : $CLIENT_ID" 
  echo "CLIENT_SECRET : $CLIENT_SECRET" 
  echo "BACKEND_URL : $BACKEND_URL" 
fi

exit 1 
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
# INSTALL & START SERVICE
if ! [ install_service $PROXY_DIR $SERVICE_FILE_NAME ]; then
  echo "Fail to create service: $SERVICE_FILE_NAME"
  exit 1
fi

########################
# INSTALL SELECTED APP #
########################

### BACKEND ###
if [ $backend - eq 1 ]; then 
  readonly BACKDIR="/usr/share/MyEasyRGPD/backend/$ORGNAME"
  readonly BACKEND_SERVICE_NAME="back.$ORGNAME.MyEasyRGPD.service"

  if ! [ -d $BACKDIR ]; then 
    #GET SOURCES
    git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git" $BACKDIR

    #SET CREDENTIALS .env
    sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$GIT_BACK/.env"
    sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$GIT_BACK/.env"
    sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$GIT_BACK/.env"
    #COPY ./environment/backend.env -> php/src/app.env
    cp "$PROGDIR/environment/backend.dev" "$GIT_BACK/php/src/app.env"
  fi

  if ! [ install_service $BACKDIR $BACKEND_SERVICE_NAME ]; then
    echo "Fail to create service: $BACKEND_SERVICE_NAME"
    exit 1
  fi
fi 

### FRONTEND ###
if [ $frontend -eq 1 ]; then
  readonly FRONTDIR="/usr/share/MyEasyRGPD/frontend/$ORGNAME"
  readonly FRONTEND_SERVICE_NAME="front.$ORGORGNAME.MyEasyRGPD.service"

  if ! [ -d $FRONTDIR ]; then 
    #GET SOURCES FILES
    git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git" $FRONTDIR

    #SET CREDENTIALS .env
    sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$FRONTDIR/.env"
    sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$FRONTDIR/.env"
    sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$FRONTDIR/.env"
    #SET CREDENTIALS docker-compose.yml
    sed -i 's,<CLIENT_ID>,'"$CLIENT_ID"',g' "$FRONTDIR/docker-compose.yml"
    sed -i 's,<CLIENT_SECRET>,'"$CLIENT_SECRET"',g' "$FRONTDIR/docker-compose.yml"
    sed -i 's,<BACKEND_URL>,'"$BACKEND_URL"',g' "$FRONTDIR/docker-compose.yml"
  fi

  if ! [ install_service $FRONTDIR $FRONTEND_SERVICE_NAME ]; then
    echo "Fail to create service: $FRONTEND_SERVICE_NAME"
    exit 1
  fi
fi



