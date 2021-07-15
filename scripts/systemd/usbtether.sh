#!/bin/dash
[ -f /tmp/usbtether.lock ] && { rm -f /tmp/usbtether.lock; exit ;}
adb wait-for-usb-device shell svc usb setFunctions rndis
