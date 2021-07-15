#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -no-custom"
notify="notify-send -h string:x-canonical-private-synchronous:usbmode"

if [ "$(adb get-state)" != device ] ; then
    $notify -t 2000 " USB mode switcher" "Device not connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
ptp="Picture Transfer"
rndis="USB Tethering"
midi="MIDI"

case $(adb shell getprop sys.usb.state) in
    *rndis*) rndis="*$rndis" ;;
    *mtp*) mtp="*$mtp" ;;
    *ptp*) ptp="*$ptp" ;;
    *midi*) midi="*$midi" ;;
    *) none="*$none" ;;
esac

case $(echo "$rndis\n$mtp\n$none\n$ptp\n$midi" | $menu -p Select USB mode) in
    "$rndis") function=rndis ;;
    "$mtp") function=mtp ;;
    "$none") function=none ;;
    "$ptp") function=ptp ;;
    "$midi") function=midi ;;
    *) exit ;;
esac

selected=$(eval "echo \"\$$function\"")

if adb shell svc usb setFunctions "$function" ; then
    $notify -t 2000 " USB mode switcher" "Successfully switched mode to \"$selected\""
else
    $notify -u critical -t 0 " USB mode switcher" "Switching mode to \"$selected\" failed!"
fi
