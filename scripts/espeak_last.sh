#!/bin/dash
lastfile=/tmp/espeak.last
pidfile="$XDG_RUNTIME_DIR/espeak.pid"

if IFS='' read -r text 2>/dev/null <"$lastfile" ; then
    if read -r PID 2>/dev/null <"$pidfile" ; then
        kill "$PID" $(pgrep -P "$PID")
        exit
    fi
    trap 'rm -f "$pidfile"; exit' HUP INT TERM
    echo "$$" >"$pidfile"
    espeak "$text"
    rm -f "$pidfile"
else
    notify-send -t 2000 Espeak "Last text not available"
fi
