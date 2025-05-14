#!/bin/dash

case "$1" in
    1)
        id="$(xinput list | awk -F'id=' '/PixArt USB Optical Mouse/ {gsub(/\t.*/, "", $2); print $2}')"
        output="$(xinput list-props "$id")" || exit
        if echo "$output" | grep "Coordinate Transformation Matrix (149):	1" ; then
            notify-send -t 1000 dwm 'Mouse movement disabled!'
            xinput set-prop "$id" 149 0 0 0 0 0 0 0 0 1
        else
            notify-send -t 1000 dwm 'Mouse movement enabled!'
            xinput set-prop "$id" 149 1 0 0 0 1 0 0 0 1
        fi
        ;;
    2)
        notify-send -t 0 dwm 'Never let the future disturb you. You will meet it, if you have to, with the same weapons of reason which today arm you against the present.\n\nIf we are not totally blind, what we are seeking is already here. This is it!\n\nSeeking what is true is not seeking what is desirable.'
        ;;
    3)
        case "$(xdotool getmouselocation)" in
            "x:970 y:430"*) ;;
                *) xdotool mousemove --sync 970 430 click 10 ;;
        esac
        ;;
esac
