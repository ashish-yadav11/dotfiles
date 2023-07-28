#!/bin/sh
aptsfile=/home/ashish/.local/share/calcurse/apts

printf "%s" "Import event(s) in calcurse? [Y/n]: "
read -r confirm
[ "$confirm" = n ] || [ "$confirm" = N ] && exit
if calcurse -i "$1" >/dev/null 2>&1 ; then
    awk '!x[$0] {x[$0]=1; print}' "$aptsfile" >/tmp/apts.temp
    mv /tmp/apts.temp "$aptsfile"
fi
