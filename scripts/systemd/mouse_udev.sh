#!/bin/dash
id="$(xinput list | awk -F'id=' '/PixArt USB Optical Mouse/ {gsub(/\t.*/, "", $2); print $2}')"
xinput set-prop "$id" 149 0 0 0 0 0 0 0 0 1
xinput set-button-map "$id" 91 92 93
