#!/usr/bin/env bash

set -e

source /usr/local/bin/functions.sh

zfs_send_to_beast $1
