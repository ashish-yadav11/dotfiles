#!/bin/dash
dunstify -r 1856 -t 1000 "Reflector" "Reflector initiated"
if sudo /home/ashish/.scripts/reflector.sh ; then
    dunstify -r 1856 "Reflector" "Pacman mirrorlist was successfully updated"
else
    dunstify -r 1856 "Reflector" "Some error occured in updating the mirrorlist"
fi
