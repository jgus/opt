#!/bin/bash -e

umount /var/cache/build-ext || true
zfs destroy root/var/cache/build-ext || true
zfs create -V 256G -s root/var/cache/build-ext
sleep 1
mkfs.ext4 /dev/zvol/root/var/cache/build-ext
mount /var/cache/build-ext
chmod a+w /var/cache/build-ext
