#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:maintenance"

dm=$(date +%d%m)
date=${dm%??}
month=${dm#??}
if [ "$date" -le 07 ] && [ "$(( month % 2 ))" -eq 0 ] ; then
    $notify -t 0 "Time for system maintenance" "1) Upgrade — packages, vim plugins, zsh plugins, suckless stuff\n2) Clean — Bleachbit, Cache of uninstalled packages\n3) Backup"
else
    $notify -t 0 "Upgrade system"
fi
