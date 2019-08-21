#!/usr/bin/env bash

set -e

chmod 600 ~/opt/dotfiles/ssh/config

for x in ssh bash_profile bashrc
do
	[ -L ~/.${x} ] || { rm -rf ~/.${x} ; ln -s ~/opt/dotfiles/${x} ~/.${x} ; }
done

~/opt/bin/allow_ssh.sh jgus
