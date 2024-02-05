#!/bin/bash
notify="notify-send -h int:transient:1"

mtpclean=/home/ashish/.scripts/mtpclean.sh
envfile=/tmp/android-mount.env

[[ -f "$envfile" ]] ||
    { echo "Error: envfile doesn't exist!"; exit ;}

setsid -f $mtpclean

device="$(awk '
        NR==1 {d=substr($0,14,3) substr($0,18); next}
        NR==2 {v=tolower($0); next}
        NR==3 {vid=$0; next}
        NR==4 {m=tolower($0); gsub(/[ _]/,"-",m); next}
        NR==5 {mid=$0; next}
        END {i=index(m,v); if (i==0) {n=v"-"m} else {n=m};
            n=toupper(substr(n,1,1)) tolower(substr(n,2))
            print n"-"d"|"vid":"mid; f=0}
    ' "$envfile"
)"
rm -f "$envfile"
[[ -n "$device" ]] || { echo "Error: something wrong with envfile format!"; exit ;}

timeout 2 adb -d wait-for-usb-device
case "$(adb -d shell getprop sys.usb.state)" in
    *mtp*) : ;;
        *) echo "Error: device not attached in mtp mode!"; exit ;;
esac

mtpoint="$XDG_RUNTIME_DIR/mtp/${device%|*}"
mkdir -p "$mtpoint"
if aft-mtp-mount -D "${device##*|}" "$mtpoint" ; then
    shopt -s nullglob dotglob
    files=( "$mtpoint"/* )
    shopt -u nullglob dotglob
    if (( ${#files[*]} )) ; then
        $notify -t 1000 " Android" "Device mounted successfully"
    else
        $notify -u critical -t 0 " Android" "Error mounting device!"
        fusermount -u "$mtpoint" && rm -rf "$mtpoint"
    fi
else
    $notify -u critical -t 0 " Android" "Error mounting device!"
    rm -rf "$mtpoint"
fi
