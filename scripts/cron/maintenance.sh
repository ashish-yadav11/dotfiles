#!/bin/dash
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export DISPLAY=":0"
/home/ashish/.local/bin/sigdsblocks 10 # update time in status
date=$(date +%d)
if [ "$date" -le 07 ] || { [ "$date" -ge 15 ] && [ "$date" -le 21 ] ;} ; then
    notify-send -t 0 "Time for system maintenance" "1) Upgrade system\n2) Clean — Bleachbit, Timeshift log, Cache of uninstalled packages\n3) Backup"
else
    notify-send -t 0 "Upgrade system"
fi
