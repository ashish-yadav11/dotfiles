#!/bin/bash
notify="notify-send -h int:transient:1"

mtpclean=/home/ashish/.scripts/mtpclean.sh
envfile=/tmp/realme-u1-mount.env

[[ -f "$envfile" ]] ||
    { echo "Error: envfile doesn't exist!"; exit ;}

setsid -f $mtpclean

{ read -r mdl; read -r srl; read -r dev ;} <"$envfile"
rm -f "$envfile"
mdl="${mdl//[ _]/-}"
dev="${dev#/dev/bus/usb/}"
dev="${dev/\//}"
[[ -n "$mdl" && -n "$srl" && -n "$dev" ]] ||
    { echo "Error: something wrong with envfile format!"; exit ;}

mtpoint="$XDG_RUNTIME_DIR/mtp/$mdl-$srl-$dev"
mkdir -p "$mtpoint"
setsid -f go-mtpfs -usb-timeout 10000 -dev "$srl" "$mtpoint" &>"$mtpoint.log"
sleep 0.1
timeout="$(( SECONDS + 2 ))"
while (( SECONDS < timeout )) ; do
    IFS='' read -r line <"$mtpoint.log"
    [[ -z "$line" ]] && continue
    case "$line" in *"attempting reset") continue ;; *) break ;; esac
    sleep 0.1
done
case "$line" in
    *"FUSE mounted")
        $notify -t 1000 " Realme U1" "Device mounted successfully"
        ;;
    *"no MTP devices found"|*"LIBUSB_ERROR_NO_DEVICE")
        rm -rf "$mtpoint" "$mtpoint.log"
        ;;
    *)
        $notify -u critical -t 0 " Realme U1" "Error mounting device!\nline: $line"
        ;;
esac
