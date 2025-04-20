#!/bin/dash

lckfile="/tmp/doubleclick.lck"
sigfile="/tmp/doubleclick.sig"
dt=0.2

exec 9<>"$lckfile"

if flock -n 9; then
    rm -f "$sigfile"
    sleep "$dt"
    if [ -f "$sigfile" ] ; then
        rm -f "$sigfile"
    else
        playerctl play-pause
    fi
else
    if ! [ -f "$sigfile" ] ; then
        touch "$sigfile"
        playerctl next
    fi
fi
