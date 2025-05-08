#!/bin/dash
id="$(xinput list | awk -F'id=' '/PixArt USB Optical Mouse/ {gsub(/\t.*/, "", $2); print $2}')"

prop="$(xinput list-props "$id" | grep -m1 'Coordinate Transformation Matrix')"
prop="${prop#*"Matrix ("}"; prop="${prop%)*}"

xinput set-prop "$id" "$prop" 0 0 0 0 0 0 0 0 1
xinput set-button-map "$id" 91 92 93
