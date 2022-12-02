#!/bin/dash
ip=192.168.12.10

warnnotif() {
    notify-send -t 2000 " ScrCpy" "Device not connected"
}
grepwarn() {
    grep -qFm1 'WARN: Device disconnected'
}

if ping -c1 -W1 "$ip" >/dev/null ; then
    scrcpy --tcpip="$ip" --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
    if [ "$?" = 1 ] ; then
        scrcpy --tcpip --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
        [ "$?" = 1 ] && warnnotif
    fi
elif [ "$(adb devices | wc -l)" -gt 2 ] ; then
    scrcpy -d --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
    [ "$?" = 1 ] && warnnotif
else
    warnnotif
fi
