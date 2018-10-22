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
echo "Affichage resultat : " 
echo "" 
echo "org name: $ORGNAME"
echo "" 
echo "backend: $backend"
echo "" 
echo "frontend: $frontend"
echo "" 
echo "VIRTUAL_HOST: $VIRTUAL_HOST"
echo "" 
echo "LETSENCRYPT_HOST: $LETSENCRYPT_HOST"
echo ""
echo "LETSENCRYPT_EMAIL: $LETSENCRYPT_EMAIL"