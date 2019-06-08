#!/usr/bin/env bash

set -e

rm -f /etc/auto.beast

for share in $(smbclient -L beast -g -A /root/beast-credentials | grep Disk\| | sed -E 's/^.*\|(.*)\|.*$/\1/g')
do
    echo "/beast/${share} -fstype=cifs,rw,credentials=/root/beast-credentials,uid=josh,gid=josh ://beast/${share}" >>/etc/auto.beast
done
