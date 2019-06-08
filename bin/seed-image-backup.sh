#!/usr/bin/env bash

set -e

#mount /backup

#PARENT=""
#LAST=""
for i in /var/lib/libvirt/images/.snapshots/20*
do
    #nice btrfs send -vv ${PARENT} ${i} | pv > /dev/null
    #echo "nice btrfs send -vv ${PARENT} ${i} | pv | nice btrfs receive -vv /backup/@images"
    #nice btrfs send -vv ${PARENT} ${i} | pv | nice btrfs receive -vv /backup/@images
    #[[ ! -d /backup/@images/@snapshots/$(basename ${i}) ]] || continue
    #if [[ ! -d /backup/@images/$(basename ${i}) ]]
    #then
    #    if [[ "${LAST}" == "" ]]
    #    then
    #        btrfs sub create /backup/@images/$(basename ${i})
    #    else
    #        btrfs sub snap /backup/@images/${LAST} /backup/@images/$(basename ${i})
    #    fi
    #fi
    #rsync -arPx --existing --inplace --no-whole-file ${i}/ /backup/@images/$(basename ${i})
    #rsync -arPx --ignore-existing --sparse ${i}/ /backup/@images/$(basename ${i})
    #rsync -arPx --existing --inplace --no-whole-file ${i}/ /backup/@images/@
    #rsync -arPx --ignore-existing --sparse ${i}/ /backup/@images/@
    #btrfs sub snap -r /backup/@images/@ /backup/@images/$(basename ${i})
    #PARENT="-p ${i}"
    #LAST="$(basename ${i})"

    # name=$(basename ${i})
    # [[ "$(ssh root@beast 'zfs list -H -t snapshot -r d/groot/images' | grep @${name} | wc -l)" == "0" ]] || continue
    # echo "rsync -arPx --existing --inplace --no-whole-file ${i}/ root@groot:/mnt/d/groot/images"
    # rsync -arPx --existing --inplace --no-whole-file -e "ssh -T -o Compression=no -x" ${i}/ root@beast:/mnt/d/groot/images
    # rsync -arPx --ignore-existing --sparse -e "ssh -T -o Compression=no -x" ${i}/ root@beast:/mnt/d/groot/images
    # ssh root@beast "zfs snapshot d/groot/images@${name}"

    name=$(basename ${i})
    [[ "$(zfs list -H -t snapshot -r user/images | grep @${name} | wc -l)" == "0" ]] || continue
    echo "rsync -arPx --existing --inplace --no-whole-file ${i}/ root@groot:/mnt/d/groot/images"
    nice rsync -arPyx --existing --inplace --no-whole-file ${i}/ /zfs/images
    nice rsync -arPyx --ignore-existing --sparse ${i}/ /zfs/images
    zfs snapshot user/images@${name}
done

echo "rsync -arPx --existing --inplace --no-whole-file /var/lib/libvirt/images/ /zfs/images"
nice rsync -arPyx --existing --inplace --no-whole-file /var/lib/libvirt/images/ /zfs/images
nice rsync -arPyx --ignore-existing --sparse /var/lib/libvirt/images/ /zfs/images

#BASE="base-$(date +%Y%m%dT%H%M%S)"

#btrfs sub snap -r /var/lib/libvirt/images/.snapshots/${LAST} /var/lib/libvirt/images/.snapshots/${BASE}
#btrfs sub snap -r /backup/@images/${LAST} /backup/@images/${BASE}
#btrfs sub del /backup/@images/last-sync.bak || true
#btrfs mv /backup/@images/last-sync /backup/@images/last-sync.bak || true
#btrfs sub snap -r /backup/@images/${LAST} /backup/@images/last-sync
#btrfs sub del /backup/@images/last-sync.bak || true

#umount /backup
