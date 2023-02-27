#!/bin/dash
getbtnsfile=/sys/class/backlight/radeon_bl0/actual_brightness
setbtnsfile=/sys/class/backlight/radeon_bl0/brightness
notify="notify-send -h string:x-canonical-private-synchronous:brightness"

read -r btns <"$getbtnsfile"

case "$1" in
    +*)
        unit="${1#+}"
        if [ "$btns" -eq 255 ] ; then
            $notify -t 2000 Brightness "Brightness is at its maximum value of 255"
            exit
        elif [ "$btns" -gt "$(( 255 - unit ))" ] ; then
            echo 255 >"$setbtnsfile"
            $notify -t 1000 Brightness "Screen Brightness is 255/255"
            exit
        else
            actval="$(( btns + unit ))"
        fi
        ;;
    -*)
        unit="${1#-}"
        if [ "$btns" -eq 1 ] ; then
            $notify -t 2000 Brightness "Brightness is at its minimum value of 1"
            exit
        elif [ "$btns" -le "$unit" ] ; then
            echo 1 >"$setbtnsfile"
            $notify -t 1000 Brightness "Screen Brightness is 1/255"
            exit
        else
            actval="$(( btns - unit ))"
        fi
        ;;
esac
setval="$(( unit * (actval / unit) ))"
echo "$setval" >"$setbtnsfile"
$notify -t 1000 Brightness "Screen Brightness is $setval/255"
