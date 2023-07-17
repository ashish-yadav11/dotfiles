#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu-daemon.lock"
fifofile="$XDG_RUNTIME_DIR/ytmsclu-daemon.fifo"
logfile="/home/ashish/.cache/ytmsclu-daemon.log"

exec 9<>"$lockfile"

if flock -n 9 || ! /usr/bin/echo "$*" 1<>"$fifofile" >"$fifofile" ; then
    notify-send -u critical -t 0 ytmsclu 'Something is wrong with ytmsclu-daemon!'
    echo "$(date +%Y%m%d-%H%M%S) | $*" >>"$logfile"
    echo "Error: Couldn't add job for ytmsclu-daemon\n\n" >>"$logfile"
    exit
fi
