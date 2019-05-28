#!/usr/bin/env bash
set -e

NEW_ROOT=${1}
shift

[[ "${NEW_ROOT}" != "" ]] || ( echo "No new root directory specified"; exit 1 )
[[ -d "${NEW_ROOT}" ]] || ( echo "${NEW_ROOT} does not exist (or is not a directory)"; exit 2 )

for i in /dev /dev/pts /proc /sys /run /boot/efi
do
    mkdir -p "${NEW_ROOT}${i}" || true
    mount -B "${i}" "${NEW_ROOT}${i}" || true
done

chroot "${NEW_ROOT}" "$@"
