#!/usr/bin/env bash

############################################
### UNINSTALL OF DOCKER & DOCKER-COMPOSE ###
### - PACMAN VERSION                        ###
############################################

#REMOVE DOCKER-COMPOSE
rm -rf /usr/local/bin/docker-compose

#REMOVE DOCKER
pacman -Rs -y docker-ce