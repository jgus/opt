#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

ssh -4 root@jarvis zfs create d/restore || true
ssh -4 root@jarvis zfs create d/restore/jail || true
ssh -4 root@jarvis zfs create d/restore/scratch || true
ssh -4 root@jarvis zfs create d/restore/external || true
ssh -4 root@jarvis zfs create d/restore/external/brown || true
ssh -4 root@jarvis zfs create d/restore/system || true
ssh -4 root@jarvis zfs create d/restore/bulk || true

# DATASETS=(
#     hot
#     warm
#     incoming
#     cold
#     jail/nightcrawler
#     jail/syncthing_1
#     scratch/published
# )

# zfs_send_new_snapshots "" bak/beast/root root@jarvis d/restore/boot

# for x in "${DATASETS[@]}"
# do
#     zfs_send_new_snapshots "" bak/beast/${x} root@jarvis d/restore/${x}
# done

# ssh -4 root@jarvis zfs mount -a

# rsync -arP --delete /bak/beast/system/ root@jarvis:/d/restore/system
# rsync -arP --delete /bak/beast/external/ root@jarvis:/d/restore/external
# for d in Backup Photos-Projects Software
# do
#     rsync -arP --delete --delete-before /bak/beast/bulk/${d} root@jarvis:/d/restore/bulk
# done
rsync -arP --delete --delete-before /ext/beast/Media root@jarvis:/d/restore/bulk
#rsync -arP --delete --delete-before root@jarvis:/mnt/d/scratch/Peer /bak/beast/scratch/
