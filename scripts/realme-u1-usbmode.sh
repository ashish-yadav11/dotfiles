#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -no-custom"
mount=/home/ashish/.scripts/realme-u1-mount.sh

exec 9<>/tmp/realme-u1-usbmode.lock
flock 9

if ! lsusb | grep -qm1 'ID 22d9:' || [ "$(adb get-state)" != device ] ; then
    notify-send -t 2000 " Realme U1" "Device not connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
ptp="Picture Transfer"
rndis="USB Tethering"
midi="MIDI"

case $(adb shell getprop sys.usb.state) in
    *rndis*) rndis="*$rndis"; items="$mtp\n$none\n$rndis\n$ptp\n$midi" ;;
    *mtp*) mtp="*$mtp"; items="$rndis\n$none\n$mtp\n$ptp\n$midi" ;;
    *ptp*) ptp="*$ptp"; items="$rndis\n$mtp\n$none\n$midi\n$ptp" ;;
    *midi*) midi="*$midi"; items="$rndis\n$mtp\n$none\n$ptp\n$midi" ;;
    *) none="*$none"; items="$rndis\n$mtp\n$ptp\n$midi\n$none" ;;
esac
case $(echo "$items" | $menu -p Select) in
    "$mtp") function=mtp ;;
    "$rndis") function=rndis ;;
    "$none") function=none ;;
    "$ptp") function=ptp ;;
    "$midi") function=midi ;;
    *) exit ;;
esac
: >/tmp/realme-u1-tether.lock
[ "$function" = mtp ] && setsid -f timeout 5 $mount
adb shell svc usb setFunctions "$function"

while adb wait-for-usb-device ; do
    case $(adb shell getprop sys.usb.state) in *"$function"*) break ;; esac
done
flock -u 9