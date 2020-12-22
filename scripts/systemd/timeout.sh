#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:timeout"

PID=$(pidof -s /usr/bin/i3lock) && tail --pid="$PID" -f /dev/null
while true ; do
    sleep 3300
    id=$($notify -p -t 0 "Timeout in 5 minutes")
    sleep 300
    dunstify -C "$id"
    feh -FNY /home/ashish/Pictures/timeout.jpg
done
