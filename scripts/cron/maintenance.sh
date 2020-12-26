#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:maintenance"

date=$(date +%d)
if [ "$date" -le 07 ] || [ "$date" -ge 15 ] && [ "$date" -le 21 ] ; then
    $notify -t 0 "Time for system maintenance" "1) Upgrade system\n2) Clean — Bleachbit, Cache of uninstalled packages\n3) Backup"
else
    $notify -t 0 "Upgrade system"
fi
