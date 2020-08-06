#!/bin/dash
case "$1" in
    sel)
        word=$(xclip -seletion primary -out)
        if [ -z "$word" ] ; then
            notify-send -t 2000 "Espeak" "Nothing in primary selection"
            exit
        fi
        ;;
    last)
        read -r PID </tmp/espeak.pid && [ -n "$PID" ] && { rkill "$PID"; exit ;}
        read -r word </tmp/espeak.last
        if [ -n "$word" ] ; then
            espeak "$word"
        else
            notify-send -t 2000 "Espeak" "Last word not available"
        fi
        exit
        ;;
    *)
        word=$(yad --image=gespeaker --no-buttons --entry --text=Espeak --entry-label="Text:")
        [ -z "$word" ] && exit
        ;;
esac

read -r PID </tmp/espeak.pid && [ -n "$PID" ] && rkill "$PID"
trap 'rm -f /tmp/espeak.pid' EXIT INT TERM
echo "$$" >/tmp/espeak.pid
echo "$word" >/tmp/espeak.last
espeak "$word"
