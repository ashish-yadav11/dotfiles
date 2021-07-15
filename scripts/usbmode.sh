#!/bin/dash
lockfile=/tmp/usbtether.lock
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -no-custom"
notify="notify-send -h string:x-canonical-private-synchronous:usbmode"

if [ "$(adb get-state)" != device ] ; then
    $notify -t 2000 " USB mode switcher" "No device connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
ptp="Picture Transfer"
rndis="USB Tethering"
midi="MIDI"

case $(adb shell getprop sys.usb.state) in
    *rndis*)
        rndis="*$rndis"
        items="$mtp\n$none\n$ptp\n$midi\n$rndis"
        ;;
    *mtp*)
        mtp="*$mtp"
        items="$rndis\n$none\n$ptp\n$midi\n$mtp"
        ;;
    *ptp*)
        ptp="*$ptp"
        items="$rndis\n$mtp\n$none\n$midi\n$ptp"
        ;;
    *midi*)
        midi="*$midi"
        items="$rndis\n$mtp\n$none\n$ptp\n$midi"
        ;;
    *)
        none="*$none"
        items="$rndis\n$mtp\n$ptp\n$midi\n$none"
        ;;
esac

case $(echo "$items" | $menu -p Select USB mode) in
    "$mtp") function=mtp ;;
    "$rndis") function=rndis ;;
    "$none") function=none ;;
    "$ptp") function=ptp ;;
    "$midi") function=midi ;;
    *) exit ;;
esac

if adb shell svc usb setFunctions "$function" ; then
    :> "$lockfile"
else
    $notify -u critical -t 0 " USB mode switcher" "Switching mode failed!"
fi
