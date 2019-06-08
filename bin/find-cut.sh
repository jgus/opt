#!/usr/bin/env bash

set -e

TARGET="$1"
POSITION_BEGIN="$2"
POSITION_END="$3"

SMALLEST_SIZE=999999999
SMALLEST_POSITION=0

for (( i=POSITION_BEGIN*100; i<=POSITION_END*100; i=i+20 ))
do
	rm -f dummy-frame.png
	ffmpeg -nostats -loglevel 0 -ss $((i/100)).$(printf "%02d" $((i%100))) -i "${TARGET}" -vframes 1 dummy-frame.png
	SIZE=$(wc -c < dummy-frame.png)
	rm dummy-frame.png
	# echo "$((i/100)).$(printf "%02d" $((i%100))): ${SIZE}"
	if ((SIZE<SMALLEST_SIZE))
	then
		SMALLEST_SIZE=${SIZE}
		SMALLEST_POSITION=${i}
	fi
done

# echo "$((SMALLEST_POSITION/100)).$(printf "%02d" $((SMALLEST_POSITIONi%100))): ${SMALLEST_SIZE}"
echo "$((SMALLEST_POSITION/100)).$(printf "%02d" $((SMALLEST_POSITIONi%100)))"
