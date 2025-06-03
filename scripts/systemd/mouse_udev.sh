#!/bin/dash
id="$(xinput list | awk -F'id=' '/PixArt USB Optical Mouse/ {gsub(/\t.*/, "", $2); print $2}')"
[ -n "$id" ] || exit 0

prop="$(xinput list-props "$id" | grep -m1 'Coordinate Transformation Matrix')"
prop="${prop#*"Matrix ("}"; prop="${prop%)*}"
[ -n "$prop" ] || exit 0

xinput set-prop "$id" "$prop" 0 0 0 0 0 0 0 0 1
xinput set-button-map "$id" 91 92 93
