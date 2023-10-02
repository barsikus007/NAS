# NAS

## TODO

- hardware
  - rockpi-penta header
  - npu
  - button
  - top fan 40x10mm 3-pin RYB and cut upper ring
  - heatsink or microfan on cpu
  - RTC battery
- software
  - https fuck
  - ldap
  - /tank/docker
- software late
  - plex vs jellyfin
  - jackett vs <https://github.com/sergiotapia/magnetissimo>
  - <https://github.com/ramanlabs-in/hachi>
- publication late
  - device specific section in readme
  - pin versions
    - traefik 3 ?
  - change passwds and ssh-rsa after complete setup

## ZFS

### TODO 1

Some Final Thoughts
Because keeping snapshots is very cheap, it's recommended to snapshot your datasets frequently. Sun Microsystems provided a Time Slider that was part of the GNOME Nautilus file manager. Time Slider keeps snapshots in the following manner:

frequent- snapshots every 15 mins, keeping 4 snapshots
hourly- snapshots every hour, keeping 24 snapshots
daily- snapshots every day, keeping 31 snapshots
weekly- snapshots every week, keeping 7 snapshots
monthly- snapshots every month, keeping 12 snapshots
Unfortunately, Time Slider is not part of the standard GNOME desktop, so it's not available for GNU/Linux. However, the ZFS on Linux developers have created a "zfs-auto-snapshot" package that you can install from the project's PPA if running Ubuntu. If running another GNU/Linux operating system, you could easily write a Bash or Python script that mimics that functionality, and place it on your root's crontab.

### TODO 2

You should put something similar to the following in your root's crontab, which will execute a scrub every Sunday at 02:00 in the morning:

0 2 ** 0 /sbin/zpool scrub tank

### TODO 3

weekly cron to backup compressed backup of zpool to 5th 2tb disk
backup root disk (emmc)
