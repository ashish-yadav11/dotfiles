#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:timeout"

trap '[ -n "$id" ] && dunstify -C "$id"; exit' TERM
while true ; do
    sleep 3300
    id=$($notify -p -t 0 "Timeout in 5 minutes")
    sleep 300
    dunstify -C "$id"
    id=""
    feh -FNY /home/ashish/Pictures/timeout.jpg
done
