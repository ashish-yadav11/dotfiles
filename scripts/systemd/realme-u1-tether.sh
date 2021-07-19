#!/bin/dash
[ -f /tmp/realme-u1-tether.lock ] && { rm -f /tmp/realme-u1-tether.lock; exit ;}
adb wait-for-usb-device shell svc usb setFunctions rndis
