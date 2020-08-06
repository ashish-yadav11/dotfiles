#!/bin/dash
PID=$(pidof -s /usr/bin/i3lock) && [ -n "$PID" ] && tail --pid="$PID" -f /dev/null
while true ; do
#    if { [ "$(date +%T)" \> "19:30:00" ] && [ "$(date +%T)" \< "20:50:00" ] ;} ||
#         [ "$(date +%T)" \< "01:20:00" ] ; then
    if [ "$(date +%T)" \< "01:20:00" ] ; then
           exit 0
    fi
    sleep 3300
    dunstify -r 192519 -t 300000 "Timeout in 5 minutes"
    sleep 300
    feh -F /home/ashish/Pictures/timeout.jpg
done
