#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

DATASETS=(
    hot
    warm
    incoming
    cold
    jail/nightcrawler
    jail/syncthing_1
    scratch/published
    external
    external/brown
)

for x in "${DATASETS[@]}"
do
    zfs_send_new_snapshots root@beast d/${x} "" bulk/beast/${x}
done
