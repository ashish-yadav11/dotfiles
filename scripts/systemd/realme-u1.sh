#!/bin/dash
mount=/home/ashish/.scripts/realme-u1-mount.sh

# to prevent udev rule from reverting manually choosen usb mode
[ -f /tmp/realme-u1.lock ] && { rm -f /tmp/realme-u1.lock; exit ;}

[ "$1" = mtp ] && setsid -f timeout 5 $mount
adb -d wait-for-usb-device shell svc usb setFunctions "$1"
