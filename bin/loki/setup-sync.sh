#!/usr/bin/env bash

set -e

ssh root@beast zfs create e/$(hostname)
ssh root@beast zfs create e/$(hostname)/z

for x in boot z/root z/home z/docker
do
    systemctl enable zfs-replicate@${x}.timer
    systemctl start zfs-replicate@${x}.timer
    systemctl start zfs-replicate@${x}.service
done
