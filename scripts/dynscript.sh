#!/bin/dash

case "$1" in
    1)
        id="$(xinput list | awk -F'id=' '/PixArt USB Optical Mouse/ {gsub(/\t.*/, "", $2); print $2}')"
        output="$(xinput list-props "$id")" || exit
        ctm="$(echo "$output" | grep -m1 'Coordinate Transformation Matrix')"
        ctm="${ctm#*"Matrix ("}"
        prop="${ctm%%)*}"
        case "$ctm" in
            "$prop):	1"*)
                notify-send -t 1000 dwm 'Mouse movement disabled!'
                xinput set-prop "$id" "$prop" 0 0 0 0 0 0 0 0 1
                ;;
            *)
                notify-send -t 1000 dwm 'Mouse movement enabled!'
                xinput set-prop "$id" "$prop" 1 0 0 0 1 0 0 0 1
                ;;
        esac
        ;;
    2)
        notify-send -t 0 dwm 'Never let the future disturb you. You will meet it, if you have to, with the same weapons of reason which today arm you against the present.\n\nIf we are not totally blind, what we are seeking is already here. This is it!\n\nSeeking what is true is not seeking what is desirable.'
        ;;
    3)
        xte "mousemove 970 430"
        ;;
esac
