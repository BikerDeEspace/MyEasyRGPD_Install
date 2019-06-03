dnf upgrade

#### INSTALL DOCKER ####
dnf install docker

systemctl start docker
systemctl enable docker

#### INSTALL DOCKER COMPOSE #### 
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
## Executable permissions to the binary
chmod +x /usr/local/bin/docker-compose