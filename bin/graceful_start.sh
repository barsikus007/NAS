#!/bin/sh

docker compose up -d --wait traefik organizr lldap authelia crowdsec loki nextcloud-aio-mastercontainer
docker compose up -d --wait grafana alloy
docker compose up -d --wait whoami transmission jellyfin tubesync syncthing vaultwarden
docker compose up -d --wait portainer whatsupdocker glances scrutiny
docker compose up -d --wait prowlarr flaresolverr radarr sonarr
# wait for low load
docker compose up -d --wait gitlab rustdesk-hbbr rustdesk-hbbs
docker compose up -d --wait notes
