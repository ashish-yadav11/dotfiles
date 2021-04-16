#!/bin/bash
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $0=="" {f=0; next}
        $1=="E: DEVNAME" {n=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); next}
        $1=="E: ID_SERIAL_SHORT" {print m"-"$2"-"n; next}
    '
)
awk '$1=="jmtpfs" {print $2}' /etc/mtab | while IFS='' read -r mtpoint ; do
    base=${mtpoint##*/}
    for device in "${devices[@]}" ; do
        [[ $base = "$device" ]] && continue 2
    done
    fusermount -u "$mtpoint" && rmdir "$mtpoint"
done
