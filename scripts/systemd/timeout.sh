#!/bin/dash
PID=$(pidof -s /usr/bin/i3lock) && tail --pid="$PID" -f /dev/null
while true ; do
    sleep 3300
    dunstify -r 192519 -t 300000 "Timeout in 5 minutes"
    sleep 300
    feh -F /home/ashish/Pictures/timeout.jpg
done
