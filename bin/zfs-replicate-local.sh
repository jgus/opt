#!/usr/bin/env bash

set -e

source=$1
target=$2

target_has_snapshot () {
    snapshot=$1
    [[ ( "${snapshot}" != "" ) && ( "$(echo $(zfs list -H -t snapshot -o name -r ${target} | grep ^${target}@${snapshot}$ | wc -l))" != "0" ) ]]
}

incremental=""
for snapshot_path in $(zfs list -H -t snapshot -s creation -o name -r ${source} | grep ^${source}@)
do
    snapshot=${snapshot_path#${source}@}
    if target_has_snapshot ${snapshot}
    then
        echo "Skipping snapshot ${snapshot}"
    else
        echo "Sending: zfs send -v ${incremental} ${snapshot_path} | zfs receive -F ${target}"
        zfs send -v ${incremental} ${snapshot_path} | zfs receive -F ${target}
    fi
    incremental="-i ${snapshot_path}"
done

echo "Done sending ${source}"
