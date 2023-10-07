# NAS

## Install

1. Install docker (ex: `curl -fsSL https://get.docker.com | sh`)
2. Copy `example.env` to `.env` and edit
   1. Edit `lscr.env`
3. Create `APPDATA_VOLUME` and `STORAGE_VOLUME` folders/mountpoints
4. Patch `apps/` configs with `./bin/config_patcher.sh` (patch will based on `.env` values)
5. Copy `apps/` to your folder specified in `APPDATA_VOLUME` env var
6. Open `80`, `443` (traefik entrypoints) and `3478` (nextcloud-talk entrypoint) ports
7. Use `docker compose up -d --build` to start
8. Config web apps manualy as pointed in section below

## GUI configuration

- LDAP (lum.$HOST/setup)
  - `./bin/config_patcher.sh && sudo cp -r patched_apps/* $APPDATA_VOLUME/`
  - `docker compose down openldap && ./bin/config_patcher.sh && sudo cp -r patched_apps/* /tank/apps/ && dcu`
- NextCloud (cloud.$HOST)
  - Enable `External storage support` app
  - LDAP TODO
- Organizr
  - LDAP ($HOST/#settings-settings-main > Authentication)
    1. Authentication Type -> Organizr DB + Backend (TODO Backend Only)
    2. Authentication Backend -> Ldap
    3. Host Address -> `ldap://openldap`
    4. Host Base DN -> `cn=%s,$LDAP_HOST`
    5. Account Prefix -> `uid=`
    6. Account Suffix -> `,ou=people,dc=ogurez,dc=duckdns,dc=org`
    7. Bind Username -> `cn=admin,dc=ogurez,dc=duckdns,dc=org`
    8. LDAP Backend Type -> OpenLDAP

## Attack surface

- fail2ban on host machine
  - 80, 443 traefik
    - 80 is unused
    - 443 refer to docker-hosted services
      - Nextcloud
      - ...
      - Rest services use organizr auth
  - 3478 nextcloud-talk
  - 51413 transmission

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
  - `-v /etc/localtime:/etc/localtime:ro`
  - ldap organizr or/and nextcloud or/and portainer
  - `/tank/docker/`
  - `apps/` patcher with `.env` values
- software late
  - stop docker if zfs not mount
  - <https://github.com/ramanlabs-in/hachi>
    - probably, on client with webdav
  - fail2ban
    - organizr
    - ldap
  - change lcdr UID GID
- publication late
  - remove quotes from labels lol
  - device specific section in readme
  - pin versions
    - traefik 3 ?
  - change passwds and ssh-rsa after complete setup

## ZFS cheatsheet

### Add scrub schedule (`0 3 * * 0 /sbin/zpool scrub tank`)

`sudo crontab -l | cat - <(echo "0 3 * * 0 /sbin/zpool scrub tank") | sudo crontab -`

### Add auto snapshot package

`sudo apt install zfs-auto-snapshot -y`

### TODO 1

weekly cron to backup compressed backup of zpool to 5th 2tb disk
backup / and /boot volumes disk (emmc)
