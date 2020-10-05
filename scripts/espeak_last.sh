#!/bin/dash
read -r PID </tmp/espeak.pid && rkill "$PID"
if read -r text </tmp/espeak.last ; then
    espeak "$text"
else
    notify-send -t 2000 "Espeak" "Last text not available"
fi
