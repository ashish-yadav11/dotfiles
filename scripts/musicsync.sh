#!/bin/dash
src=/media/storage/Music/
dst=/sdcard/Meuzik

expected_device='List of devices attached
ZD222HWT7V	device'

if [ "$(adb devices)" != "$expected_device" ] ; then
    echo "Unsupported (number of) adb devices!"
    exit 1
fi
adbsync --adb-flag d --exclude 'archive' --exclude 'long' --del push "$src" "$dst" 2>&1 |
    awk 'flag {print; next}; $0=="SYNCING" {flag=1; print "adbsync: starting sync"}'
