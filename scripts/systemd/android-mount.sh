#!/bin/bash
notify="notify-send -h int:transient:1"

mtpclean=/home/ashish/.scripts/mtpclean.sh
envfile=/tmp/android-mount.env

[[ -f "$envfile" ]] ||
    { echo "Error: envfile doesn't exist!"; exit ;}

setsid -f $mtpclean

device="$(awk '
    NR==1 {v=toupper(substr($0,1,1)) tolower(substr($0,2)); V=toupper(v); next}
    NR==2 {M=toupper($0); next}
    NR==3 {S=$0; next}
    NR==4 {D=substr($0,14,3) substr($0,18); next}
    END {i=index(M,V);
        if (i==1) {M=substr(M,length(V)+2); sub(/[ _].*/,"",M); m=v"-"M}
        else if (i==0) {sub(/[ _].*/,"",M); m=v"-"M}
        else {m=M};
        print m"-"S"-"D"|"S; f=0}
    ' "$envfile"
)"
rm -f "$envfile"
[[ -n "$device" ]] || { echo "Error: something wrong with envfile format!"; exit ;}

timeout 1 adb -d wait-for-usb-device
case "$(adb -d shell getprop sys.usb.state)" in
    *mtp*) : ;;
        *) echo "Error: device not attached in mtp mode!"; exit ;;
esac

mtpoint="$XDG_RUNTIME_DIR/mtp/${device%|*}"
mkdir -p "$mtpoint"
setsid -f go-mtpfs -usb-timeout 10000 -dev "${device##*|}" "$mtpoint" &>"$mtpoint.log"
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
    *"no MTP devices found"|*"LIBUSB_ERROR_NO_DEVICE"|*"closing connection."|*"LIBUSB_ERROR_IO")
        rm -rf "$mtpoint" "$mtpoint.log"
        ;;
    *)
        $notify -u critical -t 0 " Android" "Error mounting device!\nline: $line"
        ;;
esac
