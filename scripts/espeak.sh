#!/bin/dash
case "$1" in
    sel)
        text=$(xclip -seletion primary -out)
        if [ -z "$text" ] ; then
            notify-send -t 2000 "Espeak" "Nothing in primary selection"
            exit
        fi
        ;;
    last)
        if read -r PID </tmp/espeak.pid ; then
            rkill "$PID"
        elif read -r text </tmp/espeak.last ; then
            espeak "$text"
        else
            notify-send -t 2000 "Espeak" "Last text not available"
        fi
        exit
        ;;
    *)
        text=$(yad --image=gespeaker --no-buttons --entry --text=Espeak --entry-label="Text:")
        [ -z "$text" ] && exit
        ;;
esac

read -r PID </tmp/espeak.pid && rkill "$PID"
trap 'rm -f /tmp/espeak.pid; exit' EXIT HUP INT TERM
echo "$$" >/tmp/espeak.pid
echo "$text" >/tmp/espeak.last
espeak "$text"
