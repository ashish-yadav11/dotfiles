#!/bin/bash
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $1=="E: DEVNAME" {d=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_VENDOR" {v=tolower($2); next}
        $1=="E: ID_MODEL" {m=tolower($2); gsub(/[ _]/,"-",m); next}
        $0=="" {i=index(m,v); if (i==0) {n=v"-"m} else {n=m};
            n=toupper(substr(n,1,1)) tolower(substr(n,2))
            print n"-"d; f=0; next}
    '
)
awk '$1=="aft-mtp-mount" && $2~/^\/run\/user\/[0-9]*\/mtp\// {print $2}' /etc/mtab |
    while IFS='' read -r mtpoint ; do
        base="${mtpoint##*/}"
        for device in "${devices[@]}" ; do
            [[ "$device" == "$base" ]] && continue 2
        done
        fusermount -u "$mtpoint" && rm -rf "$mtpoint"
    done
