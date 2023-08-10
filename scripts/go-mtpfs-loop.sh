#!/bin/dash
mtpclean=/home/ashish/.scripts/mtpclean.sh

serial="$1"
mtpoint="$2"
logfile="$3"

mountwatch() {
    mkdir -p "$mtpoint"
    touch "$logfile"
    go-mtpfs -usb-timeout 15000 -dev "$serial" "$mtpoint" >"$logfile" 2>&1 &
    tail -f "$logfile" --pid="$!" |
        while read -r line ; do
            case "$line" in
                *"fatal error LIBUSB_ERROR_NO_DEVICE; closing connection.")
                    # will eventually lead to the death of go-mtpfs, and thus tail
                    fusermount -u "$mtpoint"
                    rm -f "$logfile"
                    ;;
            esac
        done
}

while true ; do
    mountwatch
    [ -f "$logfile" ] && { $mtpclean; exit ;}
done
