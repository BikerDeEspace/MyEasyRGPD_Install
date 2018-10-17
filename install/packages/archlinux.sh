#!/usr/bin/env bash

##########################################
### INSTALL OF DOCKER & DOCKER-COMPOSE ###
### - PACMAN VERSION                   ###
##########################################

#### INSTALL DOCKER ####
##Update the pacman package index
pacman -Syu -y
## Install required packages.
pacman -S -y apt-transport-https ca-certificates curl net-tools software-properties-common 

## Install the latest version of Docker CE
pacman -S -y docker-ce

#### INSTALL DOCKER COMPOSE #### 
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
## Executable permissions to the binary
chmod +x /usr/local/bin/docker-compose