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
		ORGNAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
		;;
  #Application
	-b|--backend)
		backend=1
		;;
	-f|--frontend)
		frontend=1
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