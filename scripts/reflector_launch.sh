#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/reflector.lock"
notify="notify-send -h string:x-canonical-private-synchronous:reflector"
reflector=/home/ashish/.scripts/reflector.sh

exec 9<>"$lockfile"
if ! flock -n 9 ; then
    $notify -u critical -t 2000 Reflector "Reflector is already running!"
    exit
fi

$notify -t 1000 Reflector "Reflector initiated"
if sudo $reflector ; then
    $notify Reflector "Pacman mirrorlist was successfully updated"
else
    $notify -u critical Reflector "Some error occured in updating the mirrorlist"
fi
flock -u 9
rm -f "$lockfile"
