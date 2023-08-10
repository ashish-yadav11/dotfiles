#!/bin/dash

# to prevent udev rule from reverting manually choosen usb mode
[ -f /tmp/realme-u1.lock ] && { rm -f /tmp/realme-u1.lock; exit ;}

adb -d wait-for-usb-device shell svc usb setFunctions "$1"
