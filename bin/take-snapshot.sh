#!/usr/bin/env bash

set -e

source "$( dirname "${BASH_SOURCE[0]}" )/functions.sh"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" ; pwd )"

NAME="$(date +%Y%m%dT%H%M%S)-${1:-unnamed}"

if [[ "${ROOT}" == "/user/local/bin" ]]
then
    ALL_ROOTS=(/ /boot /home /var/lib/libvirt/images /var/lib/docker)
else
    ALL_ROOTS=(${ROOT})
fi

for root in ${ALL_ROOTS[@]}
do
    take_snapshot ${root} ${NAME}
done
