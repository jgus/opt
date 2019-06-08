#!/usr/bin/env bash

set -e

TARGET="$1"
POSITION="$2"

if [[ -f "${TARGET}" ]]
then
	THUMB_FILE="${TARGET%.*}.png"
	if [[ -f "${THUMB_FILE}" ]]
	then
		#echo "$THUMB_FILE already exists; skipping"
		exit
	fi
	echo "Extracting thumbnail from ${TARGET} at ${POSITION} to ${THUMB_FILE}"
	ffmpeg -ss ${POSITION} -i "${TARGET}" -vframes 1 "${THUMB_FILE}"
elif [[ -d "${TARGET}" ]]
then
	TARGET=$(cd "${TARGET}"; pwd)
	echo "Scanning directory ${TARGET}"
	for i in "${TARGET}"/*.mkv "${TARGET}"/*.mp4
	do
		if [[ -f "${i}" ]]
		then
    		"${BASH_SOURCE[0]}" "${i}" ${POSITION}
		fi
	done
else
    echo "Can't find ${TARGET}"
    exit 1
fi
