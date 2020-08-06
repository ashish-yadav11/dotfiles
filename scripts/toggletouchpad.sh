#!/bin/dash
if xinput --list-props 11 | grep -q "Device Enabled (147):	1" ; then
    xinput disable 11 && dunstify -r 24914 -t 1000 "Touchpad disabled"
else
    xinput enable 11 && dunstify -r 24914 -t 1000 "Touchpad enabled"
fi
