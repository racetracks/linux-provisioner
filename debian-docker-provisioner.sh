#!/bin/bash

set -e

TIMEZONE="Australia/Adelaide"

echo "Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
sudo sysctl -p
echo "IPv6 disabled successfully"

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose nfs-common -y

# Create necessary directories
sudo mkdir -p /opt/docker/build
sudo mkdir -p /opt/docker/run
sudo mkdir -p /opt/docker/tmp

# Set correct permissions for the directories and configuration file
sudo chmod 755 /opt/docker/run
sudo chmod 755 /opt/docker/tmp
sudo chmod 755 /opt/docker/build

# Create the docker-compose.yml file
cat > /opt/docker/build/docker-compose.yml <<EOF
version: "3"
services:
  watchtower:
    image: containrrr/watchtower
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/timezone:/etc/timezone:ro
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022 #optional
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - WATCHTOWER_INCLUDE_RESTARTING=true
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
  portainer_agent:
    image: portainer/agent
    restart: always
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022 #optional
    ports:
      - '9001:9001'
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
EOF

# Run docker-compose up against the docker-compose.yml file
cd /opt/docker/build
sudo docker-compose up -d
