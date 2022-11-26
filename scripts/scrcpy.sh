#!/bin/bash
ip=192.168.12.10

warnnotif() {
    notify-send -t 2000 " ScrCpy" "Device not connected"
}
grepwarn() {
    grep -Fqm1 'WARN: Device disconnected'
}

if ping -c1 -W1 "$ip" >/dev/null ; then
    scrcpy --tcpip="$ip" --max-size=1920 --shortcut-mod=lctrl "$@" |& grepwarn
    [[ "${PIPESTATUS[0]}" == 0 || "${PIPESTATUS[1]}" == 0 ]] || warnnotif
elif [[ "$(adb devices | wc -l)" -ge 3 ]] ; then
    scrcpy -d --max-size=1920 --shortcut-mod=lctrl "$@" |& grepwarn
    [[ "${PIPESTATUS[0]}" == 0 || "${PIPESTATUS[1]}" == 0 ]] || warnnotif
else
    warnnotif
fi
