#!/bin/bash
mtpclean=/home/ashish/.scripts/mtpclean.sh
envfile=/tmp/realme-u1-mount.env

[ -f "$envfile" ] || exit

setsid -f $mtpclean

device="$(
    awk -F= '
        $1=="DEVNAME" {d=substr($2,14,3) substr($2,18); next}
        $1=="ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); next}
        $1=="ID_SERIAL_SHORT" {s=$2; next}
        END {print m"-"s"-"d"|"s}
    ' <"$envfile"
)"
rm -f "$envfile"
[ -n "$device" ] || exit

serial="${device#*|}"
mtpoint="$XDG_RUNTIME_DIR/mtp/${device%|*}"
mkdir -p "$mtpoint"
setsid -f go-mtpfs -usb-timeout 10000 -dev "$serial" "$mtpoint" &>"$mtpoint.log"
sleep 0.1
timeout="$(( SECONDS + 2 ))"
while (( SECONDS < timeout )) ; do
    IFS='' read -r line <"$mtpoint.log" && [[ -n "$line" ]] && break
    sleep 0.1
done
case "$line" in
    *"FUSE mounted")
        notify-send -t 1500 " Realme U1" "Device mounted successfully"
        ;;
    *)
        notify-send -u critical " Realme U1" "Error mounting device!"
        rmdir "$mtpoint"
        rm -f "$mtpoint.log"
        ;;
esac
