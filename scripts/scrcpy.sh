#!/bin/dash
ip=192.168.12.10
{ ping -c1 -W1 "$ip" >/dev/null &&
    scrcpy --tcpip="$ip" --max-size=1920 --shortcut-mod=lctrl ;} ||
        notify-send -t 2000 " ScrCpy" "Device not connected"
