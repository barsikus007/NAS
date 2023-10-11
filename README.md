# NAS

## Install

1. Install docker (ex: `curl -fsSL https://get.docker.com | sh`)
2. Copy `example.env` to `.env` and edit (also edit `lscr.env`)
3. Create `APPDATA_VOLUME` and `STORAGE_VOLUME` folders/mountpoints
4. Patch `apps/` configs with `./bin/config_patcher.sh` (patch will be based on `.env` values)
5. Copy `apps/` to your folder specified in `APPDATA_VOLUME` env var
6. Open `80`, `443` (traefik entrypoints) and `3478` (nextcloud-talk entrypoint) ports
7. `docker compose up -d --build && sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`
   1. Use `docker compose up -d --build` to start
   2. Change the ownership of the files under `APPDATA_VOLUME` (e.g. `sudo chown -R --reference=${HOME} ${APPDATA_VOLUME}/*`) immediately after volume creation
8. Wait for containers to be in a healthy state and stop some of them to patch them `docker compose stop organizr TODO`
9. Configure web applications manually as indicated in the section below

- P.S. Do not forget to adapt jellyfin compose config to your hardware decoders

## GUI configuration

- LDAP (lum.${HOST}/setup)
  - `./bin/config_patcher.sh && sudo cp -r patched_apps/* ${APPDATA_VOLUME}/`
  - `docker compose down openldap && ./bin/config_patcher.sh && sudo cp -r patched_apps/* /tank/apps/ && docker compose up -d openldap`
- NextCloud (cloud.${HOST})
  - Enable `External storage support` app
  - LDAP TODO
- Organizr
  - LDAP (${HOST}/#settings-settings-main => Authentication)
    1. Authentication Type -> Organizr DB + Backend (TODO Backend Only)
    2. Authentication Backend -> Ldap
    3. Host Address -> `ldap://openldap`
    4. Host Base DN -> `cn=%s,${LDAP_HOST}`
    5. Account Prefix -> `uid=`
    6. Account Suffix -> `,ou=people,dc=ogurez,dc=duckdns,dc=org`
    7. Bind Username -> `cn=admin,dc=ogurez,dc=duckdns,dc=org`
    8. LDAP Backend Type -> OpenLDAP
- JellyFin
  - TODO
- *arr
  - TODO

## Attack surface

- WAN => fail2ban => docker network
  - 80, 443 traefik
    - 80 is redirected to 443
    - 443 refer to docker-hosted services
      - nextcloud
      - jellyfin
      - organizr
      - rest services uses organizr auth
  - 3478 nextcloud-talk
  - 51413 transmission
- LAN => docker network
  - 8096 jellyfin webUI
  - 1900/udp jellyfin service discovery (DNLA)
  - 7359/udp jellyfin client discovery

## Notes

- Lidarr disabled due to unusable use case for me.
  - If you need album release software, then uncomment `services.lidarr` section in `compose.yaml`
- Folder structure for media system is:
  - `${STORAGE_VOLUME}/downloads/`
    - `${STORAGE_VOLUME}/downloads/{,in}complete` for downloads
    - `${STORAGE_VOLUME}/downloads/torrents` for torrent files
    - `${STORAGE_VOLUME}/downloads/media` for *arrs and jellyfin media

## TODO

- hardware (rock-3a)
  - [rockpi-penta soft](https://github.com/barsikus007/rockpi-penta)
  - button
    - <https://github.com/barsikus007/rockpi-penta/blob/ac1a4a20e224f1166b28bf155eb1cf322610d2f8/usr/bin/rockpi-penta/misc.py#L183>
  - top fan 40x10mm 3-pin RYB and cut upper ring
    - <https://www.ozon.ru/product/ventilyator-exegate-40x40x10mm-5500rpm-ex166186rus-1125378282>
  - heatsink or microfan on cpu
    - <https://shop.allnetchina.cn/products/heat-sink-for-rock-3a>
    - <https://www.ozon.ru/search/?text=raspberry+pi+радиатор&from_global=true>
  - RTC battery
    - <https://shop.allnetchina.cn/products/rtc-battery-for-rock-pi-4>
- software
  - `.env`
    - `COMPOSE_HTTP_TIMEOUT=240`
    - `PIP_DEFAULT_TIMEOUT=100`
  - <https://hub.docker.com/r/jjm2473/jellyfin-mpp>
    - <https://launchpad.net/~liujianfeng1994/+archive/ubuntu/rockchip-multimedia>
  - `-v /etc/localtime:/etc/localtime:ro`
  - `${APPDATA_VOLUME}/transmission/:/config/` remove
  - ldap organizr or/and nextcloud or/and portainer or/and jellyfin
  - `/tank/docker/`
  - `apps/` patcher with `.env` values
  - `{$APPDATA_VOLUME}/` patcher with `.env` values
  - wireguard
  - healthchecks
- alternate software
  - seafile ? (check nextcloud speed)
  - gitea ? (instead of gitlab due to weak NAS)
- new software
  - syncthing ? (for some important folder, which supposed to be synced on every device (passwords/notes))
  - <https://github.com/immich-app/immich>
  - <https://github.com/ramanlabs-in/hachi>
    - probably, on client with webdav
- software late
  - stop docker if zfs not mount
  - fail2ban cheatsheet
    - organizr
    - ldap
  - change lcdr UID GID
- publication late
  - remove quotes from labels lol
  - device specific section in readme
  - pin versions
    - traefik 3 ?
  - change passwds and ssh-rsa after complete setup
  - check for grammar issues

## ZFS cheatsheet

### Add scrub schedule (`0 3 * * 0 /sbin/zpool scrub tank`)

`sudo crontab -l | cat - <(echo "0 3 * * 0 /sbin/zpool scrub tank") | sudo crontab -`

### Add auto snapshot package

`sudo apt install zfs-auto-snapshot -y`

### TODO 1

weekly cron to backup compressed backup of zpool to 5th 2tb disk
backup / and /boot volumes disk (emmc)
