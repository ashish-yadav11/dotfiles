#!/bin/dash

# to prevent udev rule from reverting manually chosen usb mode
[ -f /tmp/android-udev.lock ] && { rm -f /tmp/android-udev.lock; exit ;}

adb -d wait-for-usb-device shell svc usb setFunctions "$1"
