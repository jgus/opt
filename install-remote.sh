#!/usr/bin/env bash

set -e

USER=$1

echo "Cloning repo..."
ssh -4 ${USER} "[ -d ~/opt ] || git clone https://github.com/jgus/opt.git ~/opt"
echo "Installing..."
ssh -4 ${USER} "~/opt/install.sh"
echo "Copying .ssh..."
"$( dirname "${BASH_SOURCE[0]}" )/bin/bless_ssh.sh" "${USER}"
echo "Fixing up repo URL..."
ssh -4 ${USER} "cd ~/opt && git remote set-url origin git@github.com:jgus/opt.git"
echo "Done!"
