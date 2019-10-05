#!/usr/bin/env zsh

set -e

NAMESPACES=(
    -N "x=\"adobe:ns:meta/\""
    -N "rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\""
    -N "crs=\"http://ns.adobe.com/camera-raw-settings/1.0/\""
    -N "darktable=\"http://darktable.sf.net/\""
)

ROOT=$1

[[ "${ROOT}" != "" ]] && [[ -d "${ROOT}" ]] || (echo "bad directory" ; exit 1)

for i in "${ROOT}"/**/*
do
    local DT_XMP="${i}.xmp"
    local LR_XMP="${i%.*}.xmp"
    [[ -f "${DT_XMP}" ]] || continue
    [[ -f "${LR_XMP}" ]] || continue
    local DT_HAS_WB
    DT_HAS_WB=$(xml sel -T -N x="adobe:ns:meta/" -N x="adobe:ns:meta/" -N x="adobe:ns:meta/" -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" -N darktable="http://darktable.sf.net/" -t -v "x:xmpmeta/rdf:RDF/rdf:Description/darktable:history/rdf:Seq/rdf:li[@darktable:operation='temperature']/@darktable:enabled" "${DT_XMP}" || echo "0")
    echo "DT_HAS_WB: ${DT_HAS_WB}"
    [[ "${DT_HAS_WB}" != "1" ]] || continue
    local LR_WB
    LR_WB=$(xml sel -T -N x="adobe:ns:meta/" -N x="adobe:ns:meta/" -N x="adobe:ns:meta/" -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" -N crs="http://ns.adobe.com/camera-raw-settings/1.0/" -t -v "x:xmpmeta/rdf:RDF/rdf:Description/@crs:WhiteBalance" "${LR_XMP}")

    case $LR_WB in
    Daylight)
        echo "Setting daylight white balance in ${DT_XMP}..."
        xml ed -P -L -N x="adobe:ns:meta/" -N x="adobe:ns:meta/" -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" -N darktable="http://darktable.sf.net/" -s x:xmpmeta/rdf:RDF/rdf:Description/darktable:history/rdf:Seq -t elem -n liTMP \
            -i //liTMP -t attr -n "darktable:operation" -v "temperature" \
            -i //liTMP -t attr -n "darktable:enabled" -v "1" \
            -i //liTMP -t attr -n "darktable:modversion" -v "3" \
            -i //liTMP -t attr -n "darktable:params" -v "7da0ff3f0000803fe49eac3f00000000" \
            -i //liTMP -t attr -n "darktable:multi_name" -v "" \
            -i //liTMP -t attr -n "darktable:multi_priority" -v "0" \
            -i //liTMP -t attr -n "darktable:blendop_version" -v "8" \
            -i //liTMP -t attr -n "darktable:blendop_params" -v "gz11eJxjYGBgkGAAgRNODGiAEV0AJ2iwh+CRxQcA5qIZBA==" \
            -r //liTMP -v rdf:li \
            "${DT_XMP}"
            exit 0
    ;;
    *)
        echo "Unknown white balance ${LR_WB} in ${i}; skipping"
    ;;
    esac
done
