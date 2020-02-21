#!/usr/bin/env bash
set -e

TARGET=$1

scp -4 ~/.ssh/id_rsa-* ${TARGET}:~/.ssh
scp -4 ~/.ssh/config ${TARGET}:~/.ssh
scp -4 -r ~/.secrets ${TARGET}:~/.secrets