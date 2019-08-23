#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/functions.sh"

ZFS_ROOTS=( boot z/root z/home z/docker )

for source in "${ZFS_ROOTS[@]}"
do
    zfs_send_new_snapshots "" ${source} root@beast e/$(hostname)/${source}
done

echo "Sync complete"
