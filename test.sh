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

echo "ORGNAME" $ORGNAME
echo "VIRTUAL_HOST" $VIRTUAL_HOST
echo "LETSENCRYPT_HOST" $LETSENCRYPT_HOST
echo "LETSENCRYPT_EMAIL" $LETSENCRYPT_EMAIL
echo "frontend" $frontend
echo "  CLIENT_ID" $CLIENT_ID
echo "  CLIENT_SECRET" $CLIENT_SECRET
echo "  BACKEND_URL" $BACKEND_URL
echo "backend" $backend