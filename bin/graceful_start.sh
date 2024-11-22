#!/bin/sh

docker compose up -d --wait samba
docker compose up -d --wait traefik organizr lldap authelia nextcloud-aio-mastercontainer
docker compose up -d --wait whoami transmission jellyfin tubesync syncthing vaultwarden
docker compose up -d --wait portainer watchtower glances scrutiny
docker compose up -d --wait prowlarr flaresolverr radarr sonarr
# wait for low load
# docker compose up -d gitlab
