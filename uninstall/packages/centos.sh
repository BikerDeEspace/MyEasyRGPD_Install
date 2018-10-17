#!/usr/bin/env bash

############################################
### UNINSTALL OF DOCKER & DOCKER-COMPOSE ###
### - YUM VERSION                        ###
############################################

#REMOVE DOCKER-COMPOSE
rm -rf /usr/local/bin/docker-compose

# REMOVE DOCKER
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine