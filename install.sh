#!/usr/bin/env bash

set -e

BASE="$(cd "$( dirname "${BASH_SOURCE[0]}" )" ; pwd)"
PARENT="$(cd "${BASE}/.." ; pwd)"

chmod 600 ${BASE}/dotfiles/ssh/config

for x in ssh/config bash_profile bashrc zshrc zshrc-grml xsessionrc
do
	[ -L ${PARENT}/.${x} ] || { rm -rf ${PARENT}/.${x} ; ln -s ${BASE}/dotfiles/${x} ${PARENT}/.${x} ; }
done

${BASE}/bin/allow_ssh.sh jgus
