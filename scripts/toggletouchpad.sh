#!/bin/dash
touchpad="ETPS/2 Elantech Touchpad"
props=$(xinput --list-props "$touchpad")
state=${props#*Device Enabled*:	}; state=${state%%	*}
if [ "$state" = 1 ] ; then
    xinput disable "$touchpad" && dunstify -r 24914 -t 1000 "Touchpad disabled"
else
    xinput enable "$touchpad" && dunstify -r 24914 -t 1000 "Touchpad enabled"
fi
