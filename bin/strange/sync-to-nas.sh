#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

rsync -arPx --delete /boot/ /boot/bak1
rsync -arPx --delete /boot/ root@nas:/e/$(hostname)/boot

DATASETS=(
    z/root
    z/home
    $(zfs list -o name | grep \^z/home/ | grep -v /scratch\$ || true)
    z/docker
    z/volumes
    $(zfs list -o name | grep \^z/volumes/ | grep -v /scratch\$ || true)
    z/images
    $(zfs list -o name | grep \^z/images/ | grep -v /scratch\$ || true)
    z/git
    $(zfs list -o name | grep \^z/git/ | grep -v /scratch\$ || true)
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots "" ${x} root@nas e/$(hostname)/${x}
done
