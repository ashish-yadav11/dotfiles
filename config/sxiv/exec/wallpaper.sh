#!/bin/dash
xwallpaper --stretch "$1"
rm -f /home/ashish/.config/wall*
filename=$(basename "$1")
cp "$1" "/home/ashish/.config/wall.${filename##*.}"
