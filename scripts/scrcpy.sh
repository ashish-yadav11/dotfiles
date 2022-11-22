#!/bin/dash
ip=192.168.12.10

warn() {
    notify-send -t 2000 " ScrCpy" "Device not connected"
}
checkoutput() {
    grep -Fqm1 'WARN: Device disconnected' || warn
}

if ping -c1 -W1 "$ip" >/dev/null ; then
    scrcpy --tcpip="$ip" --max-size=1920 --shortcut-mod=lctrl 2>&1 | checkoutput
elif [ "$(adb devices | wc -l)" -ge 3 ] ; then
    scrcpy -d --max-size=1920 --shortcut-mod=lctrl 2>&1 | checkoutput
else
    warn
fi
