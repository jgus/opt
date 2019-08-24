#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/../functions.sh"

zfs_send_new_snapshots "" $1 root@beast e/$(hostname)/$1
