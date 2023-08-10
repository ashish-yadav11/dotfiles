#!/bin/dash
mtpclean=/home/ashish/.scripts/mtpclean.sh

serial="$1"
mtpoint="$2"
logfile="$3"

mountwatch() {
    {
        go-mtpfs -usb-timeout 15000 -dev "$serial" "$mtpoint" >"$logfile" 2>&1
        kill -USR1 "$$"
    } &
    {
        while read -r line ; do
            case "$line" in
                *"fatal error LIBUSB_ERROR_NO_DEVICE; closing connection.")
                    return 0
                    ;;
            esac
        done
    } <"$logfile"
    return 1
}

# leads read to return when go-mtpfs terminates
trap : USR1

while true ; do
    mountwatch || exit
    # mtplcean should immediately generate USR1 from the subprocess, since
    # go-mtpfs would exit. thus we need not worry about earlier USR1's
    # interrupting later read's.
    $mtpclean
    sleep 0.1
done
