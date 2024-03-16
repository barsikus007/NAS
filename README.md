# NAS

## Install

1. Install docker (ex: `curl -fsSL https://get.docker.com | sh`)
   1. [Install loki driver](https://grafana.com/docs/loki/latest/send-data/docker-driver/) `docker plugin install grafana/loki-docker-driver:2.9.5 --alias loki --grant-all-permissions`
      1. [Latest version](https://github.com/grafana/loki/releases)
      2. [Arm support](https://github.com/grafana/loki/pull/9247)
         1. Install loki driver `docker plugin install miacis/loki-docker-driver:2.9.1 --alias loki --grant-all-permissions`
2. Copy `example.env` to `.env` and edit (also edit `lscr.env`)
3. Create `APPDATA_VOLUME` and `STORAGE_VOLUME` folders/mountpoints
   <!-- Copy `apps/` to your folder specified in `APPDATA_VOLUME` env var -->
4. Open `80`, `443` (traefik entrypoints), `3478` (nextcloud-talk entrypoint) and `51413` (transmission seeding) ports in router and firewall
5. `docker compose up -d --build && sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`
   1. Use  `docker compose up -d --build --wait` or `./bin/graceful_start.sh` to start
   2. Change the ownership of the files under `APPDATA_VOLUME` (e.g. `sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`) immediately after volume creation
6. Wait for containers to be in a healthy state, then stop some of them to patch `docker compose stop organizr && ./bin/appdata_patcher.sh && docker compose up -d organizr`
7. Configure web applications manually as indicated in the section below

### P.S

- duckdns is hardcoded, to use other provider, change `.env`, `compose.yaml` and `traefik/traefik.yml`
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
  - 51413 transmission
- LAN => docker network
  - 8096 jellyfin webUI
  - 1900/udp jellyfin service discovery (DNLA)
  - 7359/udp jellyfin client discovery

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

## TODO

- hardware (rock-3a)
  - [rockpi-penta soft](https://github.com/barsikus007/rockpi-penta)
  - button
    - <https://github.com/barsikus007/rockpi-penta/blob/ac1a4a20e224f1166b28bf155eb1cf322610d2f8/usr/bin/rockpi-penta/misc.py#L183>
  - top PWM fan 5V 40x10mm 3-pin RYB and cut upper ring
  - heatsink or microfan on cpu
    - height ~15mm
      - 19x19mm cpu
      - 15x10mm ram
    - <https://shop.allnetchina.cn/products/heat-sink-for-rock-3a>
    - <https://www.ozon.ru/search/?text=raspberry+pi+радиатор&from_global=true>
  - RTC battery
    - <https://shop.allnetchina.cn/products/rtc-battery-for-rock-pi-4>
- software
  - is stopping organizr needed for patching?
  - why chown?
  - speedtest
  - move samba and traefik to brand new dir
  - maybe add separate env file for acme provider
  - jellyfin acceleration
    - `/usr/lib/jellyfin-ffmpeg-custom/ffmpeg` -> <https://media.${HOST}/web/index.html#!/encodingsettings.html>
    - <https://hub.docker.com/r/jjm2473/jellyfin-mpp>
    - <https://forum.radxa.com/t/rk3588-kodi-rkmpp-accelerated-decoding-working-out-of-box/12785/33>
    - <https://github.com/jellyfin/jellyfin-ffmpeg/issues/34>
      - <https://github.com/jellyfin/jellyfin-ffmpeg/pull/318>
    - <https://launchpad.net/~liujianfeng1994/+archive/ubuntu/rockchip-multimedia>
      - sudo add-apt-repository ppa:liujianfeng1994/rockchip-multimedia -y
      - sudo apt update -y
      - sudo apt install rockchip-multimedia-config ffmpeg -y
    - nextcloud `NEXTCLOUD_ENABLE_DRI_DEVICE`
  - ldap
    - organizr
    - nextcloud
    - jellyfin
  - patchers
    - `apps/` patcher with `.env` values
    - `{$APPDATA_VOLUME}/` patcher with `.env` values
  - bluid ssp on arm64 or check if organizr have ssp?
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
  - [syncthing](https://syncthing.net) ? (check cloud usecase)
  - [gitea](https://about.gitea.com) ? (instead of gitlab due to weak NAS)
- new software
  - syncthing ? (for some important folder, which supposed to be synced on every device (passwords/notes))
  - <https://github.com/immich-app/immich>
  - <https://github.com/ramanlabs-in/hachi>
    - probably, on client with webdav
  - <https://github.com/fallenbagel/jellyseerr>
  - <https://www.photoprism.app>
- software late
  - fail2ban
    - [traefik](https://plugins.traefik.io/plugins/628c9ebcffc0cd18356a979f/fail2-ban)
    - [organizr](https://docs.organizr.app/features/fail2ban-integration)
    - [nextcloud](https://docs.nextcloud.com/server/stable/admin_manual/installation/harden_server.html#setup-fail2ban)
  - VPN (wireguard)
    - inner
    - outer
  - change lcdr UID GID
  - change passwds and ssh-rsa after complete setup and use docker secrets
  - secure whole server with vpn or firewall
  - log level debug disable
  - enable 2FA
  - SMTP
    - authelia
  - <https://hstspreload.org/>
- readme roadmap
  - PBR section
  - check for grammar issues
- [podman](https://podman.io) migration
  - (faster than docker ?)
  - why ?
  - <https://github.com/nextcloud/all-in-one/discussions/3487>

## [ZFS cheatsheet](https://github.com/barsikus007/config/blob/master/linux/cheatsheet_server.md#zfs)

## References

- [Цикл статей: построение защищённого NAS, либо домашнего мини-сервера](https://habr.com/ru/articles/359346/)
