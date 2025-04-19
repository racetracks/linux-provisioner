#!/bin/bash

# Set the timezone
timezone="Australia/Adelaide"  # Replace with your desired timezone

# Create the Docker Compose file for Watchtower
cat > /opt/docker/watchtower/build/docker-compose.yml <<EOL
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
      - TZ=$timezone
      - UMASK_SET=022 #optional
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - WATCHTOWER_INCLUDE_RESTARTING=true
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
EOL

# Change directory to /opt/docker/watchtower/build/
cd /opt/docker/watchtower/build/

# Run docker-compose up -d for Watchtower
docker compose up -d
