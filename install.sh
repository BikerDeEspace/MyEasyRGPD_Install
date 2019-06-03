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

#INIT VAR
ORGNAME=""
LOGO_FILE=""
LOGO=0
APPLICATION=""
LETSENCRYPT_EMAIL=""
CLIENT_ID=""
CLIENT_SECRET=""
BACKEND_URL=""

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
  echo "  -o, --org"
  echo "      <Help>"
	echo
  echo "  -l, --logo"
  echo "      <Help>"
	echo
	echo "  -a, --application" 
  echo "      Mandatory option"
  echo "      Values : back, front"
  echo
	echo "  -e, --encrypt-mail"
  echo "      Mandatory option"
  echo
	echo "  -i, --client-id)"
  echo "      Frontend - Mandatory option" 
  echo
	echo "  -s, --client-secret"
  echo "      Frontend - Mandatory option"   
  echo
	echo "  -u, --backend-url"
  echo "      Frontend - Mandatory option"
  echo "      Default : http://back.myeasyrgpd.lusis.lu"
  echo
}

# CREATE & START SERVICE
install_service(){
  #1 APPDIR - #2 SERVICENAME - #3 PROGDIR
  if ! [ -f /etc/systemd/system/$2 ]; then
    echo "** Install Service $2 **"
    if ! [ -f $3/install/example.service ] ; then
      echo 'Service file not found! Please check :'
      echo " - $3/install/example.service"
      exit 1
    fi
    # Create a clean copy of the service file
    cp -f $3/install/example.service $3/install/$2
    sed -i 's,APP_DIRECTORY,'"$1"',g' $3/install/$2
    # Move the new service file in "/etc/systemd/system/" directory
    mv $3/install/$2  /etc/systemd/system/$2
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
  #1 SERVICENAME - #2 ADDRESS
  until $(curl --output /dev/null --silent --head --fail $2); do
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

#SCRIPT OPTIONS
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
  -l|--logo)
    LOGO_FILE="$2"
    ;;
  #Application
	-a|--application)
    APPLICATION=$(echo "$2" | tr '[:upper:]' '[:lower:]')
		;;
  #Proxy LetsEncryptEmail
  -e|--encrypt-mail)
    LETSENCRYPT_EMAIL="$2"
    ;;
  #Frontend credentials
	-i|--client-id)
		CLIENT_ID="$2"
		;;
	-s|--client-secret)
		CLIENT_SECRET="$2"
		;;
	-u|--backend-url)
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

#VERIFICATION OPTIONS
#CHECK GENERAL OPTIONS
if [ "$APPLICATION" = "" ]; then
  echo 'Mandatory option missing or empty [-a, --application]'
  echo 'Set "backend" or "frontend"'
  exit 1
fi
if [ "$LETSENCRYPT_EMAIL" = "" ]; then
  echo 'Mandatory option missing or empty [-e, --encrypt-mail]'
  exit 1
fi

#LOGO
if ! [ "$LOGO_FILE" = "" ]; then
  if  ! [ -f $LOGO_FILE ]; then
    echo 'Logo : Incorrect file path'
    echo "Please check : $LOGO_FILE"
    exit 1
  elif ! [[ $LOGO_FILE == *.png ]]; then
    echo '.png file expected'
    exit 1
  else
    LOGO=1
  fi
fi

case $APPLICATION in
  'back'|'backend')
    #HOSTNAME
    if [ "$ORGNAME" = "" ]; then
      ORGNAME="default"
      VIRTUAL_HOST="back.mydpia.eu"
      LETSENCRYPT_HOST="back.mydpia.eu"
    else
      VIRTUAL_HOST="back.$ORGNAME.mydpia.eu"
      LETSENCRYPT_HOST="back.$ORGNAME.mydpia.eu"
    fi
  ;;
  'front'|'frontend')
    #HOSTNAME
    if [ "$ORGNAME" = "" ]; then
      ORGNAME="default"
      VIRTUAL_HOST="front.mydpia.eu"
      LETSENCRYPT_HOST="front.mydpia.eu"
    else
      VIRTUAL_HOST="$ORGNAME.mydpia.eu"
      LETSENCRYPT_HOST="$ORGNAME.mydpia.eu"
    fi

    #CLIENT CREDENTIALS
    if [ "$CLIENT_ID" = "" ]; then
        echo 'Mandatory option missing or empty [-i, --client-id]'
        exit 1
    fi
    if [ "$CLIENT_SECRET" = "" ]; then
        echo 'Mandatory option missing or empty [-s, --client-secret]'
        exit 1
    fi
    if [ "$BACKEND_URL" = "" ]; then
        BACKEND_URL="http://back.mydpia.eu"
        echo "BACKEND_URL set by default : $BACKEND_URL"
    fi
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
echo "  - ORGNAME : $ORGNAME"
echo "  - VIRTUAL HOST : $VIRTUAL_HOST"
echo "  - LETSENCRYPT HOST : $LETSENCRYPT_HOST"
echo "  - LETSENCRYPT EMAIL : $LETSENCRYPT_EMAIL"
if [ $APPLICATION == "front" ]; then
  echo "  FRONTEND CREDENTIALS :"
  echo "  - CLIENT ID : $CLIENT_ID" 
  echo "  - CLIENT SECRET : $CLIENT_SECRET" 
  echo "  - BACKEND URL : $BACKEND_URL" 
fi

#ASK FOR CONFIRM BEFORE CONTINUE
read -r -p "Is this correct? [y/N] " response
response=${response,,}
if ! [[ "$response" =~ ^(yes|y)$ ]]; then
  exit 1
fi

#PACKAGES INSTALL
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
  'fedora')
    PACKDIR="$PROGDIR/install/packages/fedora.sh"
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

#START DOCKER
systemctl start docker.service

#PROXY INSTALL
readonly PROXY_GIT=https://github.com/BikerDeEspace/nginx-proxy.git
readonly PROXY_SERVICE_NAME="MyEasyRGPD_Proxy.service"
readonly PROXY_DIR="/srv/www/nginx-proxy"
readonly PROXY_NETWORK="nginx-proxy"

#GET SOURCES IF NOT EXIST
if ! [ -f "$PROXY_DIR/docker-compose.yml" ]; then

  #CHECK PORT 80
  if $(sudo netstat -tulpn | grep LISTEN | grep -E 80) ; then
      echo "Proxy : Port 80 already used!"
      exit 1
  fi
  #GET PROXY
  git clone $PROXY_GIT $PROXY_DIR
  #CREATE NETWORK

  docker network create --driver bridge $PROXY_NETWORK || true
fi
# INSTALL & START SERVICE
if ! install_service $PROXY_DIR $PROXY_SERVICE_NAME $PROGDIR ; then
  echo "Fail to create service: $PROXY_SERVICE_NAME"
  exit 1
fi

#INSTALL SELECTED APP
### BACKEND ###
case $APPLICATION in
  'back') 
    readonly APPDIR="/usr/share/MyEasyRGPD/backend/$ORGNAME"
    readonly APP_SERVICE_NAME="back.$ORGNAME.MyEasyRGPD.service"

    if ! [ -d $APPDIR ]; then 
      #GET SOURCES
      git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Backend.git" $APPDIR

      #CREATE TMP .env FILE
      cp -f "$PROGDIR/environment/backend.env" "$PROGDIR/environment/tmp.env"
      #SET CREDENTIALS .env
      sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$PROGDIR/environment/tmp.env"
      sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$PROGDIR/environment/tmp.env"
      sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$PROGDIR/environment/tmp.env"
      #COPY ./environment/tmp.env -> php/src/app.env & .env
      cp -f "$PROGDIR/environment/tmp.env" "$APPDIR/php/app.env"
      mv -f "$PROGDIR/environment/tmp.env" "$APPDIR/.env"
      #SET LOGO
      if [ $LOGO -eq 1 ]; then
        cp $LOGO_FILE "$APPDIR/php/src/public/assets/img/pia-lab.png"
        cp $LOGO_FILE "$APPDIR/php/src/public/assets/img/pia-lab-small.png"
      fi
    fi
  ;;
'front')
  readonly APPDIR="/usr/share/MyEasyRGPD/frontend/$ORGNAME"
  readonly APP_SERVICE_NAME="front.$ORGNAME.MyEasyRGPD.service"

  if ! [ -d $APPDIR ]; then 
    #GET SOURCES FILES
    git clone "https://github.com/BikerDeEspace/MyEasyRGPD_Frontend.git" $APPDIR

    #SET CREDENTIALS .env
    sed -i 's,<VIRTUAL_HOST>,'"$VIRTUAL_HOST"',g' "$APPDIR/.env"
    sed -i 's,<LETSENCRYPT_HOST>,'"$LETSENCRYPT_HOST"',g' "$APPDIR/.env"
    sed -i 's,<LETSENCRYPT_EMAIL>,'"$LETSENCRYPT_EMAIL"',g' "$APPDIR/.env"
    #SET CLIENT CREDENTIALS docker-compose.yml
    sed -i 's,<CLIENT_ID>,'"$CLIENT_ID"',g' "$APPDIR/docker-compose.yml"
    sed -i 's,<CLIENT_SECRET>,'"$CLIENT_SECRET"',g' "$APPDIR/docker-compose.yml"
    sed -i 's,<BACKEND_URL>,'"$BACKEND_URL"',g' "$APPDIR/docker-compose.yml"
    #SET LOGO
    if [ $LOGO -eq 1 ]; then
      cp $LOGO_FILE "$APPDIR/app/src/src/assets/images/pia-lab.png"
      cp $LOGO_FILE "$APPDIR/app/src/src/assets/images/pia-lab-small.png"
    fi
  fi
  ;;
  *)
  echo "Application : Unknown $APPLICATION"
  exit 1
  ;;
esac

#CREATE SERVICE
if ! install_service $APPDIR $APP_SERVICE_NAME $PROGDIR ; then
  echo "Fail to create service: $APP_SERVICE_NAME"
  exit 1
fi

#END SCRIPT - WAIT FOR WEBSITE
wait_for_website $APP_SERVICE_NAME $VIRTUAL_HOST


#BACKEND POST INSTALL
if [ "$APPLICATION" = "back" ] || [ "$APPLICATION" = "backend" ]; then
  /usr/local/bin/docker-compose -f $APPDIR/docker-compose.yml exec backend-php ./post_install_scripts/post_install.sh
fi