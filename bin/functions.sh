#!/usr/bin/env bash

set -e

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

rsync_to_beast () {
    source=$1
    target=$2
    rsync -Praxy --existing --inplace --no-whole-file -e "ssh -T -o Compression=no -x" ${source}/ root@beast:/mnt/d/groot/${target}
    rsync -Praxy --delete --ignore-existing --sparse -e "ssh -T -o Compression=no -x" ${source}/ root@beast:/mnt/d/groot/${target}

}

zfs_beast_has_snapshot () {
    source=$1
    target=d/groot/${source}
    snapshot=$2
    [[ ( "${snapshot}" != "" ) && ( "$(ssh root@beast zfs list -H -t snapshot -o name -r ${target} | grep ^${target}@${snapshot}$ | wc -l)" != "0" ) ]]
}

zfs_send_to_beast () {
    source=$1
    target=d/groot/${source}

    incremental=""
    for snapshot_path in $(zfs list -H -t snapshot -s creation -o name -r ${source} | grep ^${source}@)
    do
        snapshot=${snapshot_path#${source}@}
        if zfs_beast_has_snapshot ${source} ${snapshot}
        then
            echo "Skipping snapshot ${snapshot}"
        else
            echo "Sending: zfs send -v ${incremental} ${snapshot_path} | ssh root@beast zfs receive -F ${target}"
            zfs send -v ${incremental} ${snapshot_path} | ssh root@beast zfs receive -F ${target}
        fi
        incremental="-i ${snapshot_path}"
    done

    echo "Done sending ${source}"
}

zfs_prune_sent_to_beast () {
    source=$1
    target=d/groot/${source}

    previous=""
    for snapshot_path in $(zfs list -H -t snapshot -s creation -o name -r ${source} | grep ^${source}@)
    do
        snapshot=${snapshot_path#${source}@}
        if ! zfs_beast_has_snapshot ${source} ${snapshot}
        then
            echo "Beast doesn't have ${snapshot}; ending prune"
            return
        fi
        if [[ "${previous}" != "" ]]
        then
            echo "Pruning local snapshot ${source}@${previous}"
            zfs destroy ${source}@${previous}
        fi
        previous="${snapshot}"
    done

    echo "Done pruning ${source}"
}
