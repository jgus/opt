#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

for x in boot z/root z/home z/docker
do
    zfs_send_new_snapshots "" ${x} root@beast e/$(hostname)/${x}
done
