#!/bin/dash
case $1 in
    selection)
        if read -r PID </tmp/espeak.pid ; then
            kill "$PID" $(pgrep -P "$PID")
            exit
        fi
        text=$(xsel -op)
        if [ -z "$text" ] ; then
            notify-send -t 2000 Espeak "Nothing in primary selection"
            exit
        fi
        ;;
    *)
        read -r PID </tmp/espeak.pid && kill "$PID" $(pgrep -P "$PID")
        text=$(yad --image=gespeaker --no-buttons --entry --text=Espeak --entry-label="Text:")
        [ -z "$text" ] && exit
        ;;
esac

trap 'rm -f /tmp/espeak.pid; exit' HUP INT TERM
echo "$$" >/tmp/espeak.pid
echo "$text" >/tmp/espeak.last
espeak "$text"
rm -f /tmp/espeak.pid
