#!/bin/bash
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $1=="E: DEVNAME" {d=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); next}
        $1=="E: ID_SERIAL_SHORT" {print m"-"$2"-"d; next}
        $0=="" {f=0; next}
    '
)
awk '$1=="rawBridge" && $2~/^\/run\/user\/[0-9]*\/mtp\// {print $2}' /etc/mtab |
    while IFS='' read -r mtpoint ; do
        base=${mtpoint##*/}
        for device in "${devices[@]}" ; do
            [[ $device == "$base" ]] && continue 2
        done
        if fusermount -u "$mtpoint" ; then
            rmdir "$mtpoint"
            rm -f "$mtpoint.log"
        fi
    done
