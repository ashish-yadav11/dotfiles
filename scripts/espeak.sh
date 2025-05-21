#!/bin/dash
lastfile=/tmp/espeak.last
pidfile="$XDG_RUNTIME_DIR/espeak.pid"

case "$1" in
    selection)
        if read -r PID 2>/dev/null <"$pidfile" ; then
            kill "$PID" $(pgrep -P "$PID")
            exit
        fi
        text="$(xsel -op)"
        if [ -z "$text" ] ; then
            notify-send -t 2000 Espeak "Nothing in primary selection!"
            exit
        fi
        ;;
    *)
        read -r PID 2>/dev/null <"$pidfile" && kill "$PID" $(pgrep -P "$PID")
        text="$(yad --image=speaker --no-buttons --entry --text=Espeak --entry-label="Text:")"
        [ -z "$text" ] && exit
        ;;
esac

trap 'rm -f "$pidfile"; exit' HUP INT TERM
echo "$$" >"$pidfile"
echo "$text" >"$lastfile"
espeak "$text"
rm -f "$pidfile"
