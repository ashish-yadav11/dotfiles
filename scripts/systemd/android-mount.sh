#!/bin/bash
notify="notify-send -h int:transient:1"

mtpclean=/home/ashish/.scripts/mtpclean.sh
envfile=/tmp/android-mount.env

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
timeout="$(( SECONDS + 2 ))"
{
    while (( SECONDS < timeout )) ; do
        sleep 0.1
        IFS='' read -r line
        [[ -z "$line" ]] && continue
        case "$line" in *"attempting reset") continue ;; *) break ;; esac
    done
} <"$mtpoint.log"
[[ -z "$line" ]] && exit
case "$line" in
    *"FUSE mounted")
        $notify -t 1000 " Android" "Device mounted successfully"
        ;;
    *"no MTP devices found"|*LIBUSB_ERROR_NO_DEVICE|*"LIBUSB_ERROR_PIPE; closing connection.")
        rm -rf "$mtpoint" "$mtpoint.log"
        ;;
    *)
        $notify -u critical -t 0 " Android" "Error mounting device!\nline: $line"
        ;;
esac
