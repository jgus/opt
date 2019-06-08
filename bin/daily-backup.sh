#!/usr/bin/env bash

set -e

/usr/local/bin/backup.sh daily
for vol in system/root user/home user/docker user/images
do
	/usr/local/bin/zfs-prune.sh ${vol}
done
