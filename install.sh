#!/bin/bash

set -e

BASE="$(cd "$( dirname "${BASH_SOURCE[0]}" )" ; pwd)"
PARENT="$(cd "${BASE}/.." ; pwd)"

chmod 600 ${BASE}/dotfiles/ssh/config

for x in bash_profile bashrc zshrc zshrc-grml xsessionrc
do
	[ -L ${PARENT}/.${x} ] || { rm -rf ${PARENT}/.${x} ; ln -s ${BASE}/dotfiles/${x} ${PARENT}/.${x} ; }
done
mkdir -p ${PARENT}/.ssh
cp -f ${BASE}/dotfiles/ssh/config ${PARENT}/.ssh/config

${BASE}/bin/allow_ssh.sh jgus
