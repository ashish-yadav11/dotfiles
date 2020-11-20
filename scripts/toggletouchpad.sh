#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:toggletouchpad"
touchpad="ETPS/2 Elantech Touchpad"

if xinput --list-props "$touchpad" | grep -q 'Device Enabled.*1$' ; then
    xinput disable "$touchpad" && $notify -t 1000 "Touchpad disabled"
else
    xinput enable "$touchpad" && $notify -t 1000 "Touchpad enabled"
fi
