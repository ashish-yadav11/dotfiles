#!/bin/dash
mtpclean=/home/ashish/.scripts/mtpclean.sh

if [ -f /tmp/usbtether.lock ] ; then
    read -r last </tmp/usbtether.lock
    rm -f /tmp/usbtether.lock
    [ "$last" = mtp ] && $mtpclean
else
    timeout 10 adb wait-for-usb-device shell svc usb setFunctions rndis
fi
