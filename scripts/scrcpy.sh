#!/bin/dash

warnnotif() {
    notify-send -t 2000 " ScrCpy" "Device not connected"
}

if [ "$(adb devices | wc -l)" -gt 2 ] ; then
    scrcpy --no-audio -d --shortcut-mod=lctrl,rctrl "$@"
    [ "$?" = 1 ] && warnnotif
else
    warnnotif
fi
