#!/bin/dash
aptsfile=/home/ashish/.local/share/calcurse/apts

calcurse -i "$1"
uniq "$aptsfile" /tmp/apts.temp
mv /tmp/apts.temp "$aptsfile"
notify-send -t 1000 Calcurse "Import successful"
