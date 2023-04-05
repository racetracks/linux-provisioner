TIMEZONE="Australia/Adelaide"

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nfs-common -y


# Create necessary directories
mkdir -p /opt/docker/build
mkdir -p /opt/docker/run
mkdir -p /opt/docker/tmp


mkdir -p /opt/docker/run/portainer


# Set correct permissions for the directories and configuration file

chmod 755 /opt/docker/run
chmod 755 /opt/docker/tmp
chmod 755 /opt/docker/build

mkdir -p /opt/docker/run/portainer

#!/bin/bash

# Set the timezone as a variable (change this as needed)
TIMEZONE="Australia/Adelaide"



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
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /opt/docker/run/portainer:/data
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022 #optional
    ports:
     - 9000:9000
    labels:
      - "com.centurylinklabs.watchtower.enable=true"

EOF

# Run docker-compose up against the docker-compose.yml file
cd /opt/docker/build
docker compose up -d

