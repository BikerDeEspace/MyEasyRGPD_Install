#!/usr/bin/env bash

##########################################
### INSTALL OF DOCKER & DOCKER-COMPOSE ###
### - YUM VERSION                      ###
##########################################

#### INSTALL DOCKER ####

# Set up the repository
## Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2 curl net-tools
## set up the stable repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# Install DOCKER CE
yum install -y docker-ce

#### INSTALL DOCKER COMPOSE #### 

curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
## Executable permissions to the binary
chmod +x /usr/local/bin/docker-compose

## DEBUG Test the installation
#docker-compose --version