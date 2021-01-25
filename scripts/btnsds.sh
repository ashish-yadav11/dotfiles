#!/bin/dash
getbtnsfile=/sys/class/backlight/radeon_bl0/actual_brightness
setbtnsfile=/sys/class/backlight/radeon_bl0/brightness
notify="notify-send -h string:x-canonical-private-synchronous:brightness"

read -r btns <"$getbtnsfile"
if [ "$btns" -eq 1 ] ; then
    $notify -t 2000 Brightness "Brightness is at its minimum value of 1"
elif [ "$btns" -le 5 ] ; then
    $notify -t 2000 Brightness "Brightness can't be lowered below this point by the key"
else
    echo "$(( btns - 5 ))" >"$setbtnsfile"
    $notify -t 1000 Brightness "Screen Brightness is $(( btns - 5 ))/255"
fi
