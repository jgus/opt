#!/usr/bin/env bash
set -e

TARGET=$1

scp ~/.ssh/id_rsa-* ${TARGET}:~/.ssh
scp ~/.ssh/config ${TARGET}:~/.ssh
