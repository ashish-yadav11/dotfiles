#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:reflector"
reflector=/home/ashish/.scripts/reflector.sh

$notify -t 1000 Reflector "Reflector initiated"
if sudo $reflector ; then
    $notify Reflector "Pacman mirrorlist was successfully updated"
else
    $notify -u critical Reflector "Some error occured in updating the mirrorlist"
fi
