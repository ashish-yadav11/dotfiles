#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -multi-select -no-custom"
mtpmount=/home/ashish/.scripts/mtpmount.sh

if [ "$(adb get-state)" != device ] ; then
    notify-send -t 2000 " adb" "Device not connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
rndis="USB Tethering"

case $(adb shell getprop sys.usb.state) in
    *rndis*) current=rndis; items="$mtp\n$none" ;;
    *mtp*) current=mtp; items="$rndis\n$none" ;;
    *) current=none; items="$rndis\n$mtp" ;;
esac
case $(echo "$items" | $menu -p Select) in
    "$mtp") function=mtp ;;
    "$rndis") function=rndis ;;
    "$none") function=none ;;
    *) exit ;;
esac
adb shell svc usb setFunctions "$function"
echo -n "$current" >/tmp/usbtether.lock
[ "$function" = mtp ] && timeout 10 adb wait-for-usb-device && $mtpmount
