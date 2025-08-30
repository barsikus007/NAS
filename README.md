# NAS

## Install

1. Install docker (ex: `curl -fsSL https://get.docker.com | sh`)
2. Copy `*.env.example` files to `*.env` and edit
3. Create `APPDATA_VOLUME` and `STORAGE_VOLUME` folders/mountpoints
   <!-- Copy `apps/` to your folder specified in `APPDATA_VOLUME` env var -->
4. Open `80`, `443` (traefik entrypoints), `3478` (nextcloud-talk entrypoint) and `51413` (transmission seeding) ports in router and firewall
5. `docker compose up -d --build && sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`
   1. Use  `docker compose up -d --build --wait` or `./bin/graceful_start.sh` to start
   2. Change the ownership of the files under `APPDATA_VOLUME` (e.g. `source .env && sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`) immediately after volume creation
6. Wait for containers to be in a healthy state, then stop some of them to patch `docker compose stop organizr && ./bin/appdata_patcher.sh && docker compose up -d organizr`
7. Configure web applications manually as indicated in the section below

### P.S

- devices: compose sections
  - adapt `jellyfin` compose config to your hardware decoders
  - add your disks to `scrutiny` compose config
- TODO `subo bash -c 'echo "ignore-warnings ARM64-COW-BUG" >> ${APPDATA_VOLUME?}/gitlab/data/redis/redis.conf'`

## GUI configuration

- LLDAP `lldap.${HOST}`
  - Setup Organizr to pass auth on lldap endpoint if needed (TODO)
  - Create users
  - TODO
- NextCloud AIO `aio.cloud.${HOST}`
  - Specify `cloud.${HOST}` in certain field
  - Change TZ
  - Specify apps to install and install
    - I prefer to enable all except ClamAV (antivirus) and Docker Socket Proxy
  - Specify backup location `/tank/backup` and generate password
- NextCloud `cloud.${HOST}`
  - `/settings`
    - `/apps/disabled`
      - `/files_external` Enable `External storage support` app
      - `/user_ldap`Enable `LDAP user and group backend` app
    - `/admin/externalstorages`
      - Storage;Local;None;/tank/storage;All users
    - `/admin/ldap`
      - [TODO](https://github.com/lldap/lldap/blob/main/example_configs/nextcloud.md)
    - `/admin/overview` Create backup in AIO after setup
- Organizr `${HOST}`
  - LDAP `/#settings-settings-main` => `Authentication` => set `Bind Password`
  - Setup tabs TODO
- JellyFin `media.${HOST}`
  - `/web/index.html#!`
    - `/addplugin.html?name=LDAP%20Authentication`
      - Install LDAP plugin
      - `/dashboard.html` Shutdown (docker will reboot jellyfin)
      - `/configurationpage?name=LDAP-Auth`
      - [TODO](https://github.com/lldap/lldap/blob/main/example_configs/jellyfin.md)
    - `/networking.html` Allow remote connections to this server
  - TODO Add Media Libraries
- *arr
  - TODO

## Attack surface

- WAN => fail2ban => docker network
  - 80, 443 traefik
    - 80 is redirected to 443
    - 443 refer to docker-hosted services
      - gitlab.${HOST} (TODO)
      - whoami.${HOST} (for testing purposes)
      - media.${HOST} -> jellyfin (for non-web apps)
      - bitwarden.${HOST} -> vaultwarden (TODO)
      - cloud.${HOST} -> nextcloud (TODO)
      - auth.${HOST} -> authelia
      - rest services use authelia auth
  - 3478 nextcloud-talk
  - 22000 syncthing
  - 51413 transmission
- LAN => docker network
  - 8096 jellyfin webUI
  - 1900/udp jellyfin service discovery (DNLA)
  - 7359/udp jellyfin client discovery
  - 21027/udp syncthing client discovery

## Notes

- Domain structure:
  - `${HOST}` => organizr
    - `www.${HOST}` => organizr
    - `traefik.${HOST}` => traefik dashboard
    - TODO
- Folder structure for media system is:
  - `${STORAGE_VOLUME}/downloads/`
    - `${STORAGE_VOLUME}/downloads/{,in}complete` for downloads
    - `${STORAGE_VOLUME}/downloads/torrents` for torrent files
    - `${STORAGE_VOLUME}/downloads/media` for *arrs and jellyfin media
- Lidarr disabled due to unusable use case for me
  - If you need album release software, then uncomment `services.lidarr` section in `compose.yaml`
- Transmission alt speed enabled due to broken pcie on rock-3a to reduce overload
- Target of this build is AMD64
  - It was ARM64 before, but I fucked enough with my rock-3a
- CrowdSec cheatsheet
  - `docker compose exec crowdsec cscli metrics`
  - `docker compose exec crowdsec cscli alerts list`
  - `docker compose exec crowdsec cscli decisions list`
    - `docker compose exec crowdsec cscli decisions delete -i x.x.x.x`

## TODO

- software
  - is stopping organizr needed for patching?
  - why chown?
  - speedtest
  - move samba and traefik to brand new dir
  - maybe add separate env file for acme provider
  - ldap
    - organizr
    - nextcloud
    - jellyfin
  - patchers
    - `apps/` patcher with `.env` values
    - `{$APPDATA_VOLUME}/` patcher with `.env` values
  - organizr SSO ?
  - healthchecks ?
    - flaresolverr
    - glances
    - portainer
    - radarr
    - scrutiny
    - sonarr
    - traefik
    - whoami
- alternate software
  - [seafile](https://www.seafile.com/en/home/) ? (check nextcloud speed)
  - [gitea](https://about.gitea.com) ? (instead of gitlab, less bloated?)
- new software
  - <https://github.com/immich-app/immich>
  - <https://github.com/ramanlabs-in/hachi>
    - probably, on client with webdav
  - <https://github.com/fallenbagel/jellyseerr>
  - <https://www.photoprism.app>
- software late
  - VPN (wireguard)
    - inner
    - outer
  - security
    - change lscr.env UID GID
    - change passwds
    - change ssh-key after complete setup
    - use docker secrets
    - secure whole server with vpn and/or firewall
    - [traefik stsSeconds](https://hstspreload.org/)
  - SMTP
    - authelia
- readme roadmap
  - PBR section
  - check for grammar issues
- [podman](https://podman.io) migration
  - (better than docker ?)
  - why ?
  - <https://github.com/nextcloud/all-in-one/discussions/3487>

## [ZFS cheatsheet](https://github.com/barsikus007/config/blob/master/linux/cheatsheet_server.md#zfs)

## References

- [Цикл статей: построение защищённого NAS, либо домашнего мини-сервера](https://habr.com/ru/articles/359346/)
