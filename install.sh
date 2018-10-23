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
  echo "  -o, --org"
  echo "      <Help>"
	echo
	echo "  -a, --application" 
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

# TEST HOSTNAME & PRINT SERVICE LOGS
wait_for_website(){
  while [ ! $(curl --output /dev/null --silent --head http://$2) ] ; do
      echo 'Loading application. Please Wait'
      echo 'Logs:'
      journalctl --unit=$1 | tail -n 2
  
      if $(systemctl is-failed --quiet $1); then
          echo 'ERROR - Unknown'
          journalctl --unit=$1 | tail -n 2
          exit 1
      fi
      sleep 10
  done
  echo "Application available on:" 
  echo "-> URL: http://$2"
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
	-a|--application)
    APPLICATION=$(echo "$2" | tr '[:upper:]' '[:lower:]')
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

#CHECK GENERAL MANDATORY OPTIONS
if [ -z $APPLICATION ] || [ $APPLICATION == "" ]; then
  echo 'Mandatory option missing or empty [-a, --application]'
  echo 'Set "backend" or "frontend"'
  exit 1
fi
if [ -z $LETSENCRYPT_EMAIL ] || [ $LETSENCRYPT_EMAIL == "" ]; then
  echo 'Mandatory option missing or empty [--encrypt-mail]'
  exit 1
fi

case $APPLICATION in
  'back'|'backend')
    FRONTEND=0
    BACKEND=1
    #HOSTNAME
    if [ -z $ORGNAME ]; then
      ORGNAME="default"
      VIRTUAL_HOST="back.myeasyrgpd.lusis.lu"
      LETSENCRYPT_HOST="back.myeasyrgpd.lusis.lu"
    else
      VIRTUAL_HOST="back.$ORGNAME.myeasyrgpd.lusis.lu"
      LETSENCRYPT_HOST="back.$ORGNAME.myeasyrgpd.lusis.lu"
    fi
  ;;
  'front'|'frontend')
    BACKEND=0
    FRONTEND=1
    #HOSTNAME
    if [ -z $ORGNAME ]; then
      ORGNAME="default"
      VIRTUAL_HOST="front.myeasyrgpd.lusis.lu"
      LETSENCRYPT_HOST="front.myeasyrgpd.lusis.lu"
    else
      VIRTUAL_HOST="$ORGNAME.myeasyrgpd.lusis.lu"
      LETSENCRYPT_HOST="$ORGNAME.myeasyrgpd.lusis.lu"
    fi

    #CLIENT CREDENTIALS
    if [ -z $CLIENT_ID ] || [ $CLIENT_ID == "" ]; then
        echo 'Mandatory option missing or empty [-i, --client-id]'
        exit 1
    fi
    if [ -z $CLIENT_SECRET ] || [ $CLIENT_SECRET == "" ]; then
        echo 'Mandatory option missing or empty [-s, --client-secret]'
        exit 1
    fi
    if [ -z $BACKEND_URL ] || [ $BACKEND_URL == "" ]; then
        echo 'Mandatory option missing or empty [-u, --backend-url]'
        exit 1
    fi
  ;;
  *)
  echo "Application : Unknown $APPLICATION"
  exit 1
  ;;
esac

echo "ENVIRONMENT VARIABLES RECAP"
echo "  - ORGNAME : $ORGNAME"
echo "  - VIRTUAL_HOST : $VIRTUAL_HOST"
echo "  - LETSENCRYPT_HOST : $LETSENCRYPT_HOST"
echo "  - LETSENCRYPT_EMAIL : $LETSENCRYPT_EMAIL"
if [ $FRONTEND -eq 1 ]; then
  echo "  FRONTEND CREDENTIALS :"
  echo "  - CLIENT_ID : $CLIENT_ID" 
  echo "  - CLIENT_SECRET : $CLIENT_SECRET" 
  echo "  - BACKEND_URL : $BACKEND_URL" 
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
case $APPLICATION in
  'back'|'backend') 
    readonly APPDIR="/usr/share/MyEasyRGPD/backend/$ORGNAME"
    readonly APP_SERVICE_NAME="back.$ORGNAME.MyEasyRGPD.service"

    if ! [ -d $APPDIR ]; then 
      #GET SOURCES
      git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git" $APPDIR

      #SET CREDENTIALS .env
      sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$GIT_BACK/.env"
      sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$GIT_BACK/.env"
      sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$GIT_BACK/.env"
      #COPY ./environment/backend.env -> php/src/app.env
      cp "$PROGDIR/environment/backend.dev" "$GIT_BACK/php/src/app.env"
    fi

    if ! [ install_service $APPDIR $APP_SERVICE_NAME ]; then
      echo "Fail to create service: $APP_SERVICE_NAME"
      exit 1
    fi
  ;;
'front'|'frontend')
  readonly APPDIR="/usr/share/MyEasyRGPD/frontend/$ORGNAME"
  readonly APP_SERVICE_NAME="front.$ORGNAME.MyEasyRGPD.service"

  if ! [ -d $APPDIR ]; then 
    #GET SOURCES FILES
    git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git" $APPDIR

    #SET CREDENTIALS .env
    sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$APPDIR/.env"
    sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$APPDIR/.env"
    sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$APPDIR/.env"
    #SET CREDENTIALS docker-compose.yml
    sed -i 's,<CLIENT_ID>,'"$CLIENT_ID"',g' "$APPDIR/docker-compose.yml"
    sed -i 's,<CLIENT_SECRET>,'"$CLIENT_SECRET"',g' "$APPDIR/docker-compose.yml"
    sed -i 's,<BACKEND_URL>,'"$BACKEND_URL"',g' "$APPDIR/docker-compose.yml"
  fi

  if ! [ install_service $APPDIR $APP_SERVICE_NAME ]; then
    echo "Fail to create service: $APP_SERVICE_NAME"
    exit 1
  fi
  ;;
  *)
  echo "Application : Unknown $APPLICATION"
  exit 1
  ;;
esac

#################################
# END SCRIPT - WAIT FOR WEBSITE #
#################################
wait_for_website $APP_SERVICE_NAME $VIRTUAL_HOST


