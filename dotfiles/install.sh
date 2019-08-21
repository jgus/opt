#!/usr/bin/env bash

set -e

~/opt/bin/allow_ssh.sh jgus

chmod 600 ~/opt/dotfiles/ssh/config

for x in ssh/config bash_profile bashrc
do
	[ -L ~/.${x} ] || { rm -rf ~/.${x} ; ln -s ~/.dotfiles/${x} ~/.${x} ; }
done
