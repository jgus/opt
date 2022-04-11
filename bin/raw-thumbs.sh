#!/bin/bash

for DIR in "$@"
do
    echo " Looking in ${DIR}..."

    find "${DIR}" -name \*.pp3 -print0 | 
    while IFS= read -r -d '' PP3
    do
        RAW=${PP3%.pp3}
        if [[ "${PP3}" -nt "${RAW}" ]]
        then
            echo "Updating thumbnail in ${RAW}..."
            TEMP_FILE=$(mktemp)
            rawtherapee-cli -S -Y -j50 -o "${TEMP_FILE}.jpg" -c "${RAW}"
            case "$(exiftool -Orientation "${RAW}")" in
                *90\ CW*|*270\ CCW*)
                    jpegtran -rotate 270 -outfile "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    rm "${TEMP_FILE}.jpg"
                    mv "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    ;;
                *90\ CCW*|*270\ CW*)
                    jpegtran -rotate 90 -outfile "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    rm "${TEMP_FILE}.jpg"
                    mv "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    ;;
                *180*)
                    jpegtran -rotate 180 -outfile "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    rm "${TEMP_FILE}.jpg"
                    mv "${TEMP_FILE}-rot.jpg" "${TEMP_FILE}.jpg"
                    ;;
                *) true ;;
            esac
            #exiftool -OtherImage= -JpgFromRaw= -b "-PreviewImage<=${TEMP_FILE}.jpg" -overwrite_original "${RAW}"
            exiftool -b "-PreviewImage<=${TEMP_FILE}.jpg" -overwrite_original "${RAW}"
            rm "${TEMP_FILE}.jpg"
        fi
    done
done
