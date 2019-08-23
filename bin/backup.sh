#!/usr/bin/env bash

set -e

source /usr/local/bin/functions.sh

FAT_ROOTS=( /recovery /boot/efi )
ZFS_ROOTS=( system/root user/home user/docker user/images user/images/macos-amd user/images/macos-amd-data user/images/win-nv user/images/win-nv-data user/images/win-apps )
#LVS=( /dev/vg/win-nv )

TIME="$(date +%Y%m%dT%H%M%S)"
NAME="${TIME}-${1:-working}"

for i in $( virsh list --name --all )
do
    virsh dumpxml ${i} >/var/lib/libvirt/images/${i}.xml
done
nice tar -cpv -I pbzip2 -f /var/lib/libvirt/images/etc-libvirt-hooks.tar.bz2 /etc/libvirt/hooks

for source in "${ZFS_ROOTS[@]}"
do
    zfs snapshot ${source}@${NAME}
done

#for source in "${LVS[@]}"
#do
#    destroy_snapshot ${source} backup || true
#    take_snapshot ${source} backup
#done

#rsync -Pra /usr/local/bin/ /recovery/setup/usr/local/bin

#rsync_to_beast /recovery recovery
rsync_to_beast /boot/efi efi

for source in "${ZFS_ROOTS[@]}"
do
    zfs_send_to_beast ${source}
done

#for source in "${LVS[@]}"
#do
#    for i in /tmp/$(basename ${source})-backup/*
#    do
#        rsync_to_beast ${i} $(basename ${source})/$(basename ${i})
#    done
#done
#
#ssh root@beast "zfs snapshot d/groot@${NAME}"
#
#for source in "${LVS[@]}"
#do
#    ssh root@beast "zfs snapshot d/groot/$(basename ${source})@${NAME}"
#done
#
#for source in "${LVS[@]}"
#do
#    destroy_snapshot ${source} backup
#done

wait

echo "Backup complete: ${NAME}"
