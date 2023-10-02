#!/bin/dash
lockfile=/tmp/android-usbmode.lock
menu="dmenu -i -matching fuzzy -no-custom"
mtpclean=/home/ashish/.scripts/mtpclean.sh

exec 9<>"$lockfile"
flock 9

if [ "$(adb -d get-state)" != device ] ; then
    notify-send -t 2000 " Android" "No devices connected!"
    exit
fi

none="Charging only"
mtp="Media Transfer"
ptp="Picture Transfer"
rndis="USB Tethering"
midi="MIDI"

mrorder="$mtp\n$rndis"
#mrorder="$rndis\n$mtp"

case "$(adb -d shell getprop sys.usb.state)" in
    *mtp*) mtp="*$mtp"; items="$rndis\n$none\n$mtp\n$ptp\n$midi"; clean=1 ;;
    *ptp*) ptp="*$ptp"; items="$mrorder\n$none\n$midi\n$ptp" ;;
    *rndis*) rndis="*$rndis"; items="$mtp\n$none\n$rndis\n$ptp\n$midi" ;;
    *midi*) midi="*$midi"; items="$mrorder\n$none\n$ptp\n$midi" ;;
    *) none="*$none"; items="$mrorder\n$ptp\n$midi\n$none" ;;
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
: >/tmp/android-udev.lock

adb -d shell svc usb setFunctions "$function"
adb -d wait-for-usb-device
[ -n "$clean" ] && setsid -f $mtpclean
flock -u 9
rm -f "$lockfile"
