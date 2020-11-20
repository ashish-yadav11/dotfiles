#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:reflector"

$notify -t 1000 Reflector "Reflector initiated"
if sudo /home/ashish/.scripts/reflector.sh ; then
    $notify Reflector "Pacman mirrorlist was successfully updated"
else
    $notify Reflector "Some error occured in updating the mirrorlist"
fi
