#!/usr/bin/env bash

set -e

USER=$1

echo "Cloning repo..."
ssh ${USER} "[ -d ~/opt ] || git clone https://github.com/jgus/opt.git ~/opt"
echo "Installing..."
ssh ${USER} "~/opt/install.sh"
echo "Copying .ssh..."
"$( dirname "${BASH_SOURCE[0]}" )/bin/bless_ssh.sh" "${USER}"
echo "Fixing up repo URL..."
ssh ${USER} "cd ~/opt && git remote set-url origin git@github.com:jgus/opt.git"
echo "Done!"
