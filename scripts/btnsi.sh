#!/bin/dash
getbtnsfile=/sys/class/backlight/radeon_bl0/actual_brightness
setbtnsfile=/sys/class/backlight/radeon_bl0/brightness
notify="notify-send -h string:x-canonical-private-synchronous:brightness"

read -r btns <"$getbtnsfile"
if [ "$btns" -eq 255 ] ; then
    $notify -t 2000 Brightness "Brightness is at its maximum value of 255"
elif [ "$btns" -gt 240 ] ; then
    echo 255 >"$setbtnsfile"
    $notify -t 2000 Brightness "Screen Brightness is 255/255"
else
    echo "$(( btns + 15 ))" >"$setbtnsfile"
    $notify -t 1000 Brightness "Screen Brightness is $(( btns + 15 ))/255"
fi
