#!/usr/bin/env bash

take_snapshot () {
    root=$1
    name=$2

    if [[ "${root}" == "/var/lib/libvirt/images" ]]
    then
        for i in $( virsh list --name --all )
        do
            virsh dumpxml ${i} >/var/lib/libvirt/images/${i}.xml
        done
        nice tar -cpv -I pbzip2 -f /var/lib/libvirt/images/etc-libvirt-hooks.tar.bz2 /etc/libvirt/hooks
    fi
    
    if [[ -b ${root} ]]
    then
        base=$(basename ${root})
        snap="${base}-${name}"
        mapped="/dev/mapper/vg-${snap//-/--}"
        lvcreate -L 64G -n ${snap} -s ${root}
        kpartx -a ${mapped}
        for i in {0..15}
        do
            if [[ -b ${mapped}${i} ]]
            then
                mkdir -p /tmp/${snap}/${i}
                mount ${mapped}${i} /tmp/${snap}/${i} || rm -rf /tmp/${snap}/${i}
            fi
        done
    else
        case $(stat -f -c %T ${root}) in
        btrfs)
            btrfs sub snap -r ${root} ${root}/.snapshots/${name}
            ;;
        zfs)
            zfs snapshot $(findmnt -n -o SOURCE --target ${root})@${name}
            ;;
        *)
            echo "Don't know how to snapshot $(stat -f -c %T ${root}) in ${root}!"
            ;;
        esac
    fi
}

destroy_snapshot () {
    root=$1
    name=$2
    
    if [[ -b ${root} ]]
    then
        base=$(basename ${root})
        snap="${base}-${name}"
        mapped="/dev/mapper/vg-${snap//-/--}"
        umount -R /tmp/${snap}/* || true
        rm -rf /tmp/${snap} || true
        kpartx -d ${mapped} || true
        lvremove -y /dev/vg/${snap}
    else
        case $(stat -f -c %T ${root}) in
        btrfs)
            btrfs sub del ${root}/.snapshots/${name}
            ;;
        zfs)
            zfs destroy $(findmnt -n -o SOURCE --target ${root})@${name}
            ;;
        *)
            echo "Don't know how to snapshot $(stat -f -c %T ${root}) in ${root}!"
            ;;
        esac
    fi
}

zfs_cmd () {
    if [[ "$1" == "" ]]
    then
        echo "zfs"
    else
        echo "ssh $1 zfs"
    fi
}

zfs_list_snapshots () {
    $(zfs_cmd $1) list -H -t snapshot -o name | grep -v @znap_.\*_frequent | grep -v @znap_.\*_hourly || true
}

zfs_has_snapshot () {
    local DATASET=$1 ; shift
    local SNAPSHOT=$1 ; shift
    [[ ( "${SNAPSHOT}" == "" ) ]] && return 1
    for EXISTING in "$@"
    do
        [[ "${EXISTING}" == "${DATASET}@${SNAPSHOT}" ]] && return 0
    done
    return 1
}

zfs_send_new_snapshots() {
    local SOURCE_HOST=$1
    local SOURCE_DATASET=$2
    local TARGET_HOST=$3
    local TARGET_DATASET=$4

    local SOURCE_SNAPSHOTS_FULL
    local TARGET_SNAPSHOTS_FULL
    echo "Listing source snapshots..."
    SOURCE_SNAPSHOTS_FULL=($(zfs_list_snapshots "${SOURCE_HOST}" | grep ^${SOURCE_DATASET}@ || true))
    echo "Listing target snapshots..."
    TARGET_SNAPSHOTS_FULL=($(zfs_list_snapshots "${TARGET_HOST}" | grep ^${TARGET_DATASET}@ || true))

    echo "Processing snapshots..."
    local INCREMENTAL=""
    for SNAPSHOT_FULL in "${SOURCE_SNAPSHOTS_FULL[@]}"
    do
        SNAPSHOT=${SNAPSHOT_FULL#${SOURCE_DATASET}@}
        if zfs_has_snapshot "${TARGET_DATASET}" "${SNAPSHOT}" "${TARGET_SNAPSHOTS_FULL[@]}"
        then
            echo "Skipping snapshot ${SNAPSHOT}"
        else
            echo "Sending snapshot (${SOURCE_HOST})${SOURCE_DATASET}@${SNAPSHOT} -> (${TARGET_HOST})${TARGET_DATASET}"
            echo "$(zfs_cmd "${SOURCE_HOST}") send -v ${INCREMENTAL} ${SOURCE_DATASET}@${SNAPSHOT} | $(zfs_cmd "${TARGET_HOST}") receive -F ${TARGET_DATASET}"
            $(zfs_cmd "${SOURCE_HOST}") send -v ${INCREMENTAL} ${SOURCE_DATASET}@${SNAPSHOT} | $(zfs_cmd "${TARGET_HOST}") receive -F ${TARGET_DATASET}
        fi
        INCREMENTAL="-i ${SOURCE_DATASET}@${SNAPSHOT}"
    done

    echo "Done sending ${SOURCE_DATASET}"
}

zfs_prune_sent_snapshots() {
    local SOURCE_HOST=$1
    local SOURCE_DATASET=$2
    local TARGET_HOST=$3
    local TARGET_DATASET=$4
    echo "Pruning snapshots from ${SOURCE_HOST}:${SOURCE_DATASET} which have been sent to ${TARGET_HOST}:${TARGET_DATASET}"

    echo "Listing source snapshots..."
    local SOURCE_SNAPSHOTS_FULL
    echo "Listing target snapshots..."
    local TARGET_SNAPSHOTS_FULL
    SOURCE_SNAPSHOTS_FULL=($(zfs_list_snapshots "${SOURCE_HOST}" | grep ^${SOURCE_DATASET}@ || true))
    TARGET_SNAPSHOTS_FULL=($(zfs_list_snapshots "${TARGET_HOST}" | grep ^${TARGET_DATASET}@ || true))

    local PREVIOUS=""
    for SNAPSHOT_FULL in "${SOURCE_SNAPSHOTS_FULL[@]}"
    do
        SNAPSHOT=${SNAPSHOT_FULL#${SOURCE_DATASET}@}
        if ! zfs_has_snapshot "${TARGET_DATASET}" "${SNAPSHOT}" "${TARGET_SNAPSHOTS_FULL[@]}"
        then
            echo "Target doesn't have ${SNAPSHOT}; ending prune"
            return
        fi
        if [[ "${PREVIOUS}" != "" ]]
        then
            echo "Pruning snapshot ${SOURCE_HOST}:${SOURCE_DATASET}@${PREVIOUS}"
            $(zfs_cmd ${SOURCE_HOST}) destroy ${SOURCE_DATASET}@${PREVIOUS}
        fi
        PREVIOUS="${SNAPSHOT}"
    done

    echo "Done pruning ${SOURCE_HOST}:${SOURCE_DATASET}"
}

zfs_prune_empty_snapshots() {
    local HOST=$1
    local DATASET=$2
    echo "Pruning empty snapshots from ${HOST}:${DATASET}"

    echo "Listing snapshots..."
    local SNAPSHOTS_FULL
    SNAPSHOTS_FULL=($(zfs_list_snapshots "${HOST}" | grep ^${DATASET}@ || true))

    local PREVIOUS=""
    for SNAPSHOT_FULL in "${SNAPSHOTS_FULL[@]}"
    do
        if [[ "${PREVIOUS}" != "" ]]
        then
            DIFF=$($(zfs_cmd ${HOST}) diff -H ${PREVIOUS} ${SNAPSHOT_FULL} | wc -l)
            if [[ "${DIFF}" == "0" ]]
            then
                echo "${PREVIOUS} is empty; pruning..."
                $(zfs_cmd ${HOST}) destroy ${PREVIOUS}
            fi
        fi
        PREVIOUS="${SNAPSHOT_FULL}"
    done

    echo "Done pruning snapshots from ${HOST}:${DATASET}"
}

rsync_to_beast () {
    source=$1
    target=$2
    rsync -Praxy --existing --inplace --no-whole-file -e "ssh -T -o Compression=no -x" ${source}/ root@beast:/mnt/e/groot/${target}
    rsync -Praxy --delete --ignore-existing --sparse -e "ssh -T -o Compression=no -x" ${source}/ root@beast:/mnt/e/groot/${target}

}

zfs_beast_has_snapshot () {
    zfs_has_snapshot e/groot/$1 $2 $(zfs_list_snapshots root@beast)
}

zfs_send_to_beast () {
    zfs_send_new_snapshots "" "$1" root@beast "e/groot/$1"
}

zfs_prune_sent_to_beast () {
    zfs_prune_sent_snapshots "" "$1" root@beast "e/groot/$1"
}
