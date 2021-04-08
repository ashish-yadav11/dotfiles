#!/bin/bash

# clean stale simple-mtpfs temporary directories
find /tmp -maxdepth 1 -type d -name 'simple-mtpfs-??????' -exec rmdir {} + 2>/dev/null

# clean orphaned mount points
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $0=="" {f=0; next}
        $1=="E: DEVNAME" {n=$2; sub(/^\/dev\/bus\/usb\//,"",n); sub(/\//,"",n); next}
        $1=="E: ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); next}
        $1=="E: ID_SERIAL_SHORT" {print m"-"$2"-"n; next}
    '
)
awk '$1=="simple-mtpfs" {print $2}' /etc/mtab | while IFS='' read -r mtpoint ; do
    base=${mtpoint##*/}
    for device in "${devices[@]}" ; do
        [[ $base = "$device" ]] && continue 2
    done
    fusermount -u "$mtpoint" && rmdir "$mtpoint"
done
