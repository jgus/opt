#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

zfs create bak/beast || true
zfs create bak/beast/jail || true
zfs create bak/beast/scratch || true
zfs create bak/beast/external || true
zfs create bak/beast/external/brown || true
zfs create bak/beast/system || true
zfs create bak/beast/bulk || true

DATASETS=(
    hot
    warm
    incoming
    cold
    jail/nightcrawler
    jail/syncthing_1
    scratch/published
)

zfs_send_new_snapshots root@beast freenas-boot/ROOT/11.2-U7 "" bak/beast/root

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots root@beast d/${x} "" bak/beast/${x}
done

zfs mount -a

rsync -arP --delete root@beast:/var/db/system/ /bak/beast/system
rsync -arP --delete root@beast:/mnt/d/external/ /bak/beast/external
for d in Backup Photos-Projects Software
do
    rsync -arP --delete --delete-before root@beast:/mnt/d/bulk/${d} /bak/beast/bulk
done
rsync -arP --delete --delete-before root@beast:/mnt/d/bulk/Media /ext/beast/
#rsync -arP --delete --delete-before root@beast:/mnt/d/scratch/Peer /bak/beast/scratch/
