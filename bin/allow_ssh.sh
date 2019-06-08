#!/usr/bin/env bash
set -e

USER=${1:-jgus}

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
curl https://github.com/${USER}.keys >> ~/.ssh/authorized_keys
uniq -i ~/.ssh/authorized_keys
chmod 400 ~/.ssh/authorized_keys
