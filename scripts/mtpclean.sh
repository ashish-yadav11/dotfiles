#!/bin/bash
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $1=="E: DEVNAME" {D=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_VENDOR" {v=toupper(substr($2,1,1)) tolower(substr($2,2)); V=toupper(v); next}
        $1=="E: ID_MODEL" {M=toupper($2); next}
        $1=="E: ID_SERIAL_SHORT" {S=$2; next}
        $0=="" {i=index(M,V);
            if (i==1) {M=substr(M,length(V)+2); sub(/[ _].*/,"",M); m=v"-"M}
            else if (i==0) {sub(/[ _].*/,"",M); m=v"-"M}
            else {m=M};
            print m"-"S"-"D"; f=0; next}
    '
)
awk '$1=="rawBridge" && $2~/^\/run\/user\/[0-9]*\/mtp\// {print $2}' /etc/mtab |
    while IFS='' read -r mtpoint ; do
        base="${mtpoint##*/}"
        for device in "${devices[@]}" ; do
            [[ "$device" == "$base" ]] && continue 2
        done
        fusermount -u "$mtpoint" && rm -rf "$mtpoint" "$mtpoint.log"
    done
