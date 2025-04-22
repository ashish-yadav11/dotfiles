#!/bin/dash
ytmsclu=/home/ashish/.scripts/ytmsclu.sh

lckfile="/tmp/doublenext.lck"
sigfile="/tmp/doublenext.sig"
dt=0.3

exec 9<>"$lckfile"

if flock -n 9; then
    rm -f "$sigfile"
    sleep "$dt"
    if [ -f "$sigfile" ] ; then
        rm -f "$sigfile"
    else
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    fi
else
    if ! [ -f "$sigfile" ] ; then
        touch "$sigfile"
        $ytmsclu
    fi
fi
