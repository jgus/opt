#!/bin/sh

set -e

/usr/local/bin/take-snapshot.sh runonce

for file in /usr/local/etc/runonce.d/*
do
    [ -f "${file}" ] || continue
    "${file}"
    mkdir -p "/usr/local/etc/runonce.d/ran"
    mv "${file}" "/usr/local/etc/runonce.d/ran/$(date +%Y%m%dT%H%M%S).$(basename ${file})"
    /usr/local/bin/take-snapshot.sh "$(basename ${file})"
done
