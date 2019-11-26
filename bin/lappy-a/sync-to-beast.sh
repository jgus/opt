#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

rsync -arPx --delete /boot/ root@beast:/mnt/e/$(hostname)/boot

DATASETS=(
    z/root
    z/home
    z/docker
    z/volumes
    $(zfs list -o name | grep \^z/volumes/ | grep -v /scratch\$ || true)
    z/images
    $(zfs list -o name | grep \^z/images/ | grep -v /scratch\$ || true)
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots "" ${x} root@beast e/$(hostname)/${x}
done
