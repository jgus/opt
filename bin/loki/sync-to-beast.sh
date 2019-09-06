#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

DATASETS=(
    boot
    z/root
    z/home
    z/docker
    $(zfs list -o name | grep \^z/wineprefix/template)
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots "" ${x} root@beast e/$(hostname)/${x}
done
