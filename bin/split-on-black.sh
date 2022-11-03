#!/usr/bin/env bash

set -e

in_file="$1"
min_time="$2"
out_file="$3"
start=""
end=""

# ffmpeg -i "${in_file}" -vf "blackdetect=d=0.05:pix_th=0.10" -af "silencedetect=d=0.5" -f null - 2>&1
# ffmpeg -i "${in_file}" -vf "blackdetect=d=0.05:pix_th=0.10" -an -f null - 2>&1 | while IFS="" read -r line || [ -n "${line}" ]; do
while read line
do
  echo "=== ${line}"
  if [[ ${line} =~ start ]]
  then
    start="${line##*=}"
    if [[ $(bc <<< "${start} > ${min_time}") != "1" ]]
    then
      start=""
    fi
  fi
  if [[ ${line} =~ end ]] && [[ "${start}" != "" ]]
  then
    end="${line##*=}"
    break
  fi
done < <(ffprobe -f lavfi -i "movie=${in_file},blackdetect[out0]" -show_entries packet_tags=lavfi.black_start,lavfi.black_end | grep black)

if [[ "${start}" == "" ]] || [[ "${end}" == "" ]]
then
  echo "Failed to parse times"
  exit 1
fi

echo "Start: ${start}, End: ${end}"
break_time="$(bc <<< "scale=3; (${start}+${end})/2")"
echo "Break: ${break_time}"

out_file_1="${out_file} p1.mkv"
out_file_2="${out_file} p2.mkv"

echo ffmpeg -to ${break_time} -i "${in_file}" -c copy "${out_file_1}"
ffmpeg -to ${break_time} -i "${in_file}" -c copy "${out_file_1}"
echo ffmpeg -ss ${break_time} -i "${in_file}" -c copy "${out_file_2}"
ffmpeg -ss ${break_time} -i "${in_file}" -c copy "${out_file_2}"
