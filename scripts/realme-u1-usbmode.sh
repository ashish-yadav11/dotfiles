#!/bin/dash
menu="dmenu -i -matching fuzzy -no-custom"
mount=/home/ashish/.scripts/realme-u1-mount.sh
mtpclean=/home/ashish/.scripts/mtpclean.sh

exec 9<>/tmp/realme-u1-usbmode.lock
flock 9

if ! lsusb | grep -qm1 'ID 22d9:' || [ "$(adb -d get-state)" != device ] ; then
    notify-send -t 2000 " Realme U1" "Device not connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
ptp="Picture Transfer"
rndis="USB Tethering"
midi="MIDI"

case "$(adb -d shell getprop sys.usb.state)" in
    *mtp*) mtp="*$mtp"; items="$rndis\n$none\n$mtp\n$ptp\n$midi"; clean=1 ;;
    *ptp*) ptp="*$ptp"; items="$rndis\n$mtp\n$none\n$midi\n$ptp" ;;
    *rndis*) rndis="*$rndis"; items="$mtp\n$none\n$rndis\n$ptp\n$midi" ;;
    *midi*) midi="*$midi"; items="$rndis\n$mtp\n$none\n$ptp\n$midi" ;;
    *) none="*$none"; items="$rndis\n$mtp\n$ptp\n$midi\n$none" ;;
esac
case "$(echo "$items" | $menu -p Select)" in
    "$none") function=none ;;
    "$mtp") function=mtp ;;
    "$ptp") function=ptp ;;
    "$rndis") function=rndis ;;
    "$midi") function=midi ;;
    *) exit ;;
esac

# to prevent udev rule from reverting the choosen usb mode
: >/tmp/realme-u1.lock

[ "$function" = mtp ] && setsid -f timeout 5 $mount
adb -d shell svc usb setFunctions "$function"
adb -d wait-for-usb-device
[ -n "$clean" ] && setsid -f $mtpclean
flock -u 9
