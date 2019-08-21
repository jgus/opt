#!/usr/bin/env bash

set -e

USER=$1

echo "Cloning repo..."
ssh ${USER} "[ -d ~/opt ] || git clone https://github.com/jgus/opt.git ~/opt"
echo "Installing..."
ssh ${USER} "~/opt/dotfiles/install.sh"
echo "Copying .ssh..."
scp ~/.ssh/id_rsa-* ${USER}:~/.ssh
echo "Fixing up repo URL..."
ssh ${USER} "cd ~/opt && git remote set-url origin git@github.com:jgus/opt.git"
echo "Done!"
