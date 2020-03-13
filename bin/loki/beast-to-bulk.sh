#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

DATASETS=(
    cold
    external
    external/brown
    hot
    incoming
    jail/nightcrawler
    jail/syncthing_1
    scratch/published
    time-machine
    warm
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots root@beast d/${x} "" bulk/beast/${x}
done
