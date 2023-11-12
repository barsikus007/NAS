#!/bin/sh

docker compose up -d --wait traefik organizr openldap ldap-user-manager samba nextcloud-aio-mastercontainer
docker compose up -d --wait whoami transmission jellyfin tubesync vaultwarden
docker compose up -d --wait portainer watchtower glances scrutiny
docker compose up -d --wait prowlarr flaresolverr radarr sonarr
# wait for low load
# docker compose up -d gitlab
