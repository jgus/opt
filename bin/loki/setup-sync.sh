#!/usr/bin/env bash

set -e

ssh root@beast zfs create e/$(hostname)
ssh root@beast zfs create e/$(hostname)/z

systemctl enable zfs-replicate.timer
systemctl start zfs-replicate.timer
systemctl start zfs-replicate.service
