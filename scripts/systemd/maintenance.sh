#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:maintenance"

month="$(date +%m)"
if [ "$(( month % 2 ))" -eq 0 ] ; then
    $notify -t 0 "Time for system maintenance" "1) Upgrade\npackages, vim plugins, zsh plugins, suckless stuff\n\n2) Clean\nconfig files, dconf settings, bleachbit, cache of uninstalled packages\n\n3) Backup\n\n4) Run ytmusic stuff"
else
    $notify -t 0 "Upgrade system"
fi
