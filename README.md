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

- P.S. Do not forget to adapt jellyfin compose config to your hardware decoders
- P.S. Do not forget to add your disks to scrutiny compose config
- TODO `subo bash -c 'echo "ignore-warnings ARM64-COW-BUG" >> ${APPDATA_VOLUME?}/gitlab/data/redis/redis.conf'`

## GUI configuration

- LDAP (lum.${HOST}/setup)
  - `./bin/config_patcher.sh && sudo cp -r patched_apps/* ${APPDATA_VOLUME}/`
  - `docker compose down openldap && ./bin/config_patcher.sh && sudo cp -r patched_apps/* /tank/apps/ && docker compose up -d openldap`
- NextCloud (cloud.${HOST})
  - Enable `External storage support` app
  - LDAP TODO
- Organizr
  - LDAP `${HOST}/#settings-settings-main` => `Authentication` => set `Bind Password`
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
- Transmission alt speed enabled due to broken pcie on rock-3a

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
  - jellyfin acceleration
    - <https://hub.docker.com/r/jjm2473/jellyfin-mpp>
    - <https://launchpad.net/~liujianfeng1994/+archive/ubuntu/rockchip-multimedia>
  - `-v /etc/localtime:/etc/localtime:ro`
  - `${APPDATA_VOLUME}/transmission/:/config/` remove
  - ldap organizr or/and nextcloud or/and jellyfin
  - patchers
    - `apps/` patcher with `.env` values
    - `{$APPDATA_VOLUME}/` patcher with `.env` values
  - bluid ssp on arm64 or check if organizr have ssp?
  - healthchecks ?
    - flaresolverr
    - glances
    - jellyfin
    - lum
    - openldap
    - portainer
    - prowlarr
    - radarr
    - scrutiny
    - sonarr
    - traefik
    - transmission
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
  - [Docker on ZFS](./README.md#docker-on-zfs)
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
  - check for grammar issues
- [podman](https://podman.io) migration
  - (faster than docker ?)
  - why ?
  - <https://github.com/nextcloud/all-in-one/discussions/3487>

## ZFS cheatsheet

### Add scrub schedule (`0 3 * * 0 /sbin/zpool scrub tank`)

`sudo crontab -l | cat - <(echo "0 3 * * 0 /sbin/zpool scrub tank") | sudo crontab -`

### Add auto snapshot package

`sudo apt install zfs-auto-snapshot -y`

### Docker on ZFS

```bash
sudo zfs create -o com.sun:auto-snapshot=false tank/docker
sudo service docker stop
sudo mv /var/lib/docker/* /tank/docker/
sudo rm -rf /var/lib/docker/
sudo ln -s /tank/docker/ /var/lib/docker
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
