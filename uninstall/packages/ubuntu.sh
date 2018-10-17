#!/usr/bin/env bash

############################################
### UNINSTALL OF DOCKER & DOCKER-COMPOSE ###
### - APT VERSION                        ###
############################################

# REMOVE DOCKER COMPOSE
rm -rf /usr/local/bin/docker-compose

# REMOVE DOCKER
apt-get remove -y --purge docker-ce

# Docker stable repository
add-apt-repository --remove \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Remove Docker’s official GPG key
apt-key del 0EBFCD88

# Remove packages to allow apt to use a repository over HTTPS
apt-get remove -y --purge apt-transport-https curl net-tools software-properties-common