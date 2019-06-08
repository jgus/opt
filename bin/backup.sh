#!/usr/bin/env bash

set -e

source /usr/local/bin/functions.sh

FAT_ROOTS=( /recovery /boot/efi )
ZFS_ROOTS=( / /home /var/lib/docker /var/lib/libvirt/images )
LVS=( /dev/vg/win-nv )

TIME="$(date +%Y%m%dT%H%M%S)"
NAME="${TIME}-${1:-working}"

for source in "${ZFS_ROOTS[@]}"
do
    take_snapshot ${source} "${NAME}"
done

for source in "${LVS[@]}"
do
    destroy_snapshot ${source} backup || true
    take_snapshot ${source} backup
done

rsync -Pra /usr/local/bin/ /recovery/setup/usr/local/bin

rsync_to_beast /recovery recovery
rsync_to_beast /boot/efi efi

zfs_send_to_beast system/root
zfs_send_to_beast user/home
zfs_send_to_beast user/docker
zfs_send_to_beast user/images

for source in "${LVS[@]}"
do
    for i in /tmp/$(basename ${source})-backup/*
    do
        rsync_to_beast ${i} $(basename ${source})/$(basename ${i})
    done
done

ssh root@beast "zfs snapshot d/groot@${NAME}"

for source in "${LVS[@]}"
do
    ssh root@beast "zfs snapshot d/groot/$(basename ${source})@${NAME}"
done

for source in "${LVS[@]}"
do
    destroy_snapshot ${source} backup
done

wait

echo "Backup complete: ${NAME}"
