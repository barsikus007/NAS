#!/bin/sh

docker compose up -d --wait traefik traefik-plugins organizr lldap authelia-redis authelia crowdsec loki nextcloud-aio-mastercontainer
docker compose up -d --wait grafana alloy
docker compose up -d --wait whoami transmission jellyfin lampac tubesync syncthing
docker compose up -d --wait portainer whatsupdocker glances scrutiny
# wait for low load
docker compose up -d --wait gitlab rustdesk-hbbr rustdesk-hbbs
docker compose up -d --wait notes
