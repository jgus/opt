#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

DATASETS=(
    boot
    z/root
    z/home
    z/docker
    z/volumes
    $(zfs list -o name | grep \^z/volumes/ | grep -v /scratch\$)
    z/images
    $(zfs list -o name | grep \^z/images/ | grep -v /scratch\$)
    z/git
    $(zfs list -o name | grep \^z/git/ | grep -v /scratch\$)
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots "" ${x} root@beast e/$(hostname)/${x}
done
