#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

zfs destroy -r z/docker || true
zfs_send_new_snapshots root@beast e/$(hostname)/z/docker "" z/docker
zfs set mountpoint=/var/lib/docker z/docker
