#!/bin/dash
mtpclean=/home/ashish/.scripts/mtpclean.sh

serial="$1"
mtpoint="$2"
logfile="$3"

mountwatch() {
    touch "$logfile"
    go-mtpfs -usb-timeout 15000 -dev "$serial" "$mtpoint" >"$logfile" 2>&1 &
    tail -f "$logfile" --pid="$!" |
        while read -r line ; do
            case "$line" in
                *"fatal error LIBUSB_ERROR_NO_DEVICE; closing connection.")
                    return 0
                    ;;
            esac
        done
    return 1
}

while true ; do
    mountwatch || exit
    $mtpclean
done
