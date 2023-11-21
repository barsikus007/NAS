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
8. Wait for containers to be in a healthy state, then stop some of them to patch `docker compose stop organizr && ./bin/appdata_patcher.sh && docker compose up -d organizr`
9. Configure web applications manually as indicated in the section below

### P.S

- duckdns is hardcoded, to use other provider, change `.env`, `compose.yaml` and `traefik/traefik.yml`
- devices: compose sections
  - adapt jellyfin compose config to your hardware decoders
  - add your disks to scrutiny compose config
- weak:
  - rm `tubesync:/config/` line
    - uncomment `${APPDATA_VOLUME?}/tubesync/:/config/` line
  - rm `TRANSMISSION_ALT_SPEED_ENABLED` line
- TODO `subo bash -c 'echo "ignore-warnings ARM64-COW-BUG" >> ${APPDATA_VOLUME?}/gitlab/data/redis/redis.conf'`

## GUI configuration

- LDAP (lum.${HOST}/setup)
  - `./bin/config_patcher.sh && sudo cp -r patched_apps/* ${APPDATA_VOLUME}/`
  - `docker compose down openldap && ./bin/config_patcher.sh && sudo cp -r patched_apps/* /tank/apps/ && docker compose up -d openldap`
- NextCloud AIO (aio.cloud.${HOST})
  - Specify cloud.${HOST} in certain field
  - /tank/backup TODO
  - Change TZ
- NextCloud (cloud.${HOST})
  - Enable `External storage support` app
  - LDAP TODO
- Organizr
  - LDAP `${HOST}/#settings-settings-main` => `Authentication` => set `Bind Password`
  - Setup tabs TODO
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
      - gitlab
      - rest services uses organizr auth
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

## TODO

- hardware (rock-3a)
  - [rockpi-penta soft](https://github.com/barsikus007/rockpi-penta)
  - button
    - <https://github.com/barsikus007/rockpi-penta/blob/ac1a4a20e224f1166b28bf155eb1cf322610d2f8/usr/bin/rockpi-penta/misc.py#L183>
  - top PWM fan 5V 40x10mm 3-pin RYB and cut upper ring
  - heatsink or microfan on cpu
    - <https://shop.allnetchina.cn/products/heat-sink-for-rock-3a>
    - <https://www.ozon.ru/search/?text=raspberry+pi+радиатор&from_global=true>
  - RTC battery
    - <https://shop.allnetchina.cn/products/rtc-battery-for-rock-pi-4>
- software
  - `openldap_data:/bitnami/openldap/`
  - move samba and traefik to brand new dir
  - maybe add separate env file for acme provider
  - jellyfin acceleration
    - `/usr/lib/jellyfin-ffmpeg-custom/ffmpeg` -> <https://media.ogurez.duckdns.org/web/index.html#!/encodingsettings.html>
    - <https://hub.docker.com/r/jjm2473/jellyfin-mpp>
    - <https://launchpad.net/~liujianfeng1994/+archive/ubuntu/rockchip-multimedia>
      - sudo add-apt-repository ppa:liujianfeng1994/rockchip-multimedia -y
      - sudo apt update -y
      - sudo apt dist-upgrade -y
      - sudo apt install rockchip-multimedia-config -y
      - sudo apt install ffmpeg -y
      - sudo apt install libv4l-rkmpp v4l-utils -y
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
    - lum
    - openldap
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
  - [Docker on ZFS](./#docker-on-zfs)
  - fail2ban
    - [organizr](https://docs.organizr.app/features/fail2ban-integration)
    - [nextcloud](https://docs.nextcloud.com/server/stable/admin_manual/installation/harden_server.html#setup-fail2ban)
    - [traefik](https://plugins.traefik.io/plugins/628c9ebcffc0cd18356a979f/fail2-ban)
    - ldap ?
  - VPN (wireguard)
    - inner
    - outer
  - change lcdr UID GID
  - change passwds and ssh-rsa after complete setup
- readme roadmap
  - PBR section
  - device specific section
    - tubesync volume due to bad SATA HAT software (weak)
      - or <https://github.com/meeb/tubesync/blob/main/docs/other-database-backends.md>
  - check for grammar issues
- [podman](https://podman.io) migration
  - (faster than docker ?)
  - why ?
  - <https://github.com/nextcloud/all-in-one/discussions/3487>

## ZFS cheatsheet

### Add scrub schedule (`0 3 * * * /sbin/zpool scrub tank`)

```bash
sudo crontab -l | cat - <(echo "0 3 * * * /sbin/zpool scrub tank") | sudo crontab -
```

### Add auto snapshot package

`sudo apt install zfs-auto-snapshot -y`

### Docker on ZFS

```bash
sudo zfs create -o com.sun:auto-snapshot=false tank/docker
docker compose stop
sudo service docker stop
nvim /etc/docker/daemon.json
# add theese lines
# {
#   "storage-driver": "zfs"
# }
# backup necessary docker data and then remove
sudo rm -rf /var/lib/docker
sudo ln -s /tank/docker /var/lib/docker
sudo service docker start
```

- TODO 0 maybe need to create docker service trigger on ZFS mount?
  - <https://www.reddit.com/r/docker/comments/my6p90/docker_zfs_storage_driver_vs_storing_docker_data/>
  - <https://www.reddit.com/r/zfs/comments/10e0rkx/for_anyone_using_zfsol_with_docker/>

### TODO 1

- weekly cron to backup compressed backup of zpool to 5th 2tb disk
- backup / and /boot volumes disk (emmc)

## References

- [Цикл статей: построение защищённого NAS, либо домашнего мини-сервера](https://habr.com/ru/articles/359346/)
