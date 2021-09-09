#!/bin/bash
mtpclean=/home/ashish/.scripts/mtpclean.sh

setsid -f $mtpclean

mkfifo /tmp/realme-u1-mount.fifo
udevadm monitor -up -s usb >/tmp/realme-u1-mount.fifo &
PID="$!"
device="$(
    awk -F= '
        $1=="ACTION" && $2=="bind" {f=1; next}
        !f {next};
        $1=="DEVNAME" {d=substr($2,14,3) substr($2,18); next}
        $1=="ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); next}
        $1=="ID_SERIAL_SHORT" {b=m"-"$2"-"d"|"$2; next}
        $1=="ID_MTP_DEVICE" && $2=="1" {print b; exit}
        $0=="" {f=0; b=""; next};
    ' </tmp/realme-u1-mount.fifo
)"
kill "$PID"
rm -f /tmp/realme-u1-mount.fifo

serial="${device#*|}"
mtpoint="$XDG_RUNTIME_DIR/mtp/${device%|*}"
mkdir -p "$mtpoint"
setsid -f go-mtpfs -dev "$serial" "$mtpoint" >"$mtpoint.log" 2>&1
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
