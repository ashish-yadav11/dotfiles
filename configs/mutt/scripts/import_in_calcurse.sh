#!/bin/dash
aptsfile=/home/ashish/.local/share/calcurse/apts

read -r -p "Import event(s) in calcurse? [Y/n]: " confirm
[ "$confirm" = n ] || [ "$confirm" = N ] && exit
calcurse -i "$1" >/dev/null 2>&1
awk '!x[$0] {x[$0]=1; print}' "$aptsfile" >/tmp/apts.temp
mv /tmp/apts.temp "$aptsfile"
