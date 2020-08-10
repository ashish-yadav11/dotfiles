#!/bin/dash
read -r btns </sys/class/backlight/radeon_bl0/actual_brightness
if [ "$btns" -eq 255 ] ; then
    dunstify -r 2189 -t 2000 "Brightness" "Brightness is at its maximum value of 255"
elif [ "$btns" -gt 240 ] ; then
    echo 255 >/sys/class/backlight/radeon_bl0/brightness
    dunstify -r 2189 -t 2000 "Brightness" "Screen Brightness is 255/255"
else
    echo "$(( btns+15 ))" >/sys/class/backlight/radeon_bl0/brightness
    dunstify -r 2189 -t 1000 "Brightness" "Screen Brightness is $(( btns+15 ))/255"
fi
