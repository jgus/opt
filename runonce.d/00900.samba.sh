#!/usr/bin/env bash

set -e

apt -y install samba

(sleep 1; echo "thx-1138"; sleep 1; echo "thx-1138") | smbpasswd -s -a josh

cat <<EOF >>/etc/samba/smb.conf

[homes]
    read only = no
    browsable = yes
    create mask = 0775
    directory mask = 0775

[tmp]
    path = /tmp
    read only = no
    browsable = yes
    create mask = 0777
    directory mask = 0777
EOF

service smbd restart
