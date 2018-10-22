#!/usr/bin/env bash

##########################################
### INSTALL OF DOCKER & DOCKER-COMPOSE ###
### - APT VERSION                      ###
##########################################

#### INSTALL DOCKER ####
##Update the apt package index
apt-get update -y
## Install packages to allow apt to use a repository over HTTPS
apt-get install -y apt-transport-https ca-certificates curl net-tools software-properties-common 

## Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

## DEBUG Check key
#apt-key fingerprint 0EBFCD88

## Set up the stable repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
## Install the latest version of Docker CE
apt-get install -y docker-ce


#### INSTALL DOCKER COMPOSE #### 
if ! [ -f '/usr/local/bin/docker-compose' ] ; then
    curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    ## Executable permissions to the binary
    chmod +x /usr/local/bin/docker-compose
fi

## DEBUG Test the installation
#docker-compose --version
