#!/usr/bin/env bash

set -e

source /usr/local/bin/functions.sh

zfs_prune_sent_to_beast $1
