#!/bin/dash
touchpad="ETPS/2 Elantech Touchpad"
if xinput --list-props "$touchpad" | grep -q 'Device Enabled.*1$' ; then
    xinput disable "$touchpad" && dunstify -r 24914 -t 1000 "Touchpad disabled"
else
    xinput enable "$touchpad" && dunstify -r 24914 -t 1000 "Touchpad enabled"
fi
