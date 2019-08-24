#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

for dataset in $($(zfs_cmd root@beast) list -H -o name)
do
    zfs_prune_empty_snapshots root@beast ${dataset} || true
done

echo "Prune complete"
