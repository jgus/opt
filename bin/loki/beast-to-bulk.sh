#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

zfs create bulk/beast || true
zfs create bulk/beast/jail || true
zfs create bulk/beast/scratch || true
zfs create bulk/beast/external || true
zfs create bulk/beast/external/brown || true
zfs create bulk/beast/system || true

DATASETS=(
    hot
    warm
    incoming
    cold
    jail/nightcrawler
    jail/syncthing_1
    scratch/published
)

zfs_send_new_snapshots root@beast freenas-boot/ROOT/11.2-U7 "" bulk/beast/root

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots root@beast d/${x} "" bulk/beast/${x}
done

zfs mount -a

rsync -arP --delete root@beast:/var/db/system/ /bulk/beast/system
rsync -arP --delete root@beast:/mnt/d/external/ /bulk/beast/external
for d in Backup Photos-Projects
do
    rsync -arP --delete --delete-before root@beast:/mnt/d/bulk/${d} /bulk/beast/bulk
done
