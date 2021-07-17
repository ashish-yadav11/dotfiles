#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -multi-select -no-custom"

if [ "$(adb get-state)" != device ] ; then
    notify-send -t 2000 " adb" "Device not connected"
    exit
fi

none="Charging only"
mtp="Media Transfer"
rndis="USB Tethering"

case $(adb shell getprop sys.usb.state) in
    *rndis*) f=0 ;;
    *mtp*) f=1 ;;
    *) f=2 ;;
esac

if adb shell service call connectivity 27 |
        awk -F\' 'NR!=1 {buf=buf$2}; END {exit index(buf,"a.p.0")}' ; then
    wifi="Enable Wi-Fi Hotspot"
    wificmd="su -c service call connectivity 24 i32 0 i32 0 i32 0 s16 adb"
    case $f in
        0) items="$wifi\n$mtp + $wifi\n$mtp\n$none" ;;
        1) items="$rndis\n$wifi\n$none" ;;
        2) items="$rndis\n$wifi\n$mtp + $wifi\n$mtp" ;;
    esac
else
    wifi="Disable Wi-Fi Hotspot"
    wificmd="su -c service call connectivity 25 i32 0 s16 adb"
    case $f in
        0) items="$mtp\n$wifi\n$none" ;;
        1) items="$rndis\n$rndis + $wifi\n$wifi\n$none" ;;
        2) items="$rndis\n$mtp\n$rndis + $wifi\n$wifi" ;;
    esac
fi

case $(echo "$items" | $menu -p Select) in
    "$wifi")
        adb shell "$wificmd"
        exit
        ;;
    "$mtp + $wifi")
        adb shell "$wificmd"
        function=mtp
        ;;
    "$mtp")
        function=mtp
        ;;
    "$rndis")
        function=rndis
        ;;
    "$rndis + $wifi")
        adb shell "$wificmd"
        function=rndis
        ;;
    "$none")
        function=none
        ;;
    *)
        exit
        ;;
esac
adb shell svc usb setFunctions "$function"
:> /tmp/usbtether.lock
if [ "$function" = mtp ] ; then
    timeout 10 adb wait-for-usb-device && mtpmount
elif [ "$f" = 1 ] ; then
    timeout 10 adb wait-for-usb-device && mtpclean
fi
