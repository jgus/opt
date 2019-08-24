#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/functions.sh"

/usr/local/bin/backup.sh daily
for vol in system/root user/home user/docker user/images user/images/macos-amd user/images/macos-amd-data user/images/win-apps user/images/win-nv user/images/win-nv-data
do
	/usr/local/bin/zfs-prune.sh ${vol}
done
