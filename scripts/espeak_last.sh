#!/bin/dash
if read -r text </tmp/espeak.last ; then
    if read -r PID </tmp/espeak.pid ; then
        kill "$PID" $(pgrep -P "$PID")
        exit
    fi
    trap 'rm -f /tmp/espeak.pid; exit' HUP INT TERM
    echo "$$" >/tmp/espeak.pid
    espeak "$text"
    rm -f /tmp/espeak.pid
else
    notify-send -t 2000 Espeak "Last text not available"
fi
