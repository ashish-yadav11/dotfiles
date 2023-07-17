#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu-daemon.lock"
fifofile="$XDG_RUNTIME_DIR/ytmsclu-daemon.fifo"
logfile="/home/ashish/.cache/ytmsclu-daemon.log"
notifyerror="notify-send -u critical -t 0 ytmsclu-addjob"

exec 9<>"$lockfile"

if flock -n 9 || ! /usr/bin/echo "$*" 1<>"$fifofile" >"$fifofile" ; then
    $notifyerror "Error: ytmsclu-daemon not running!"
    echo "$(date +%Y%m%d-%H%M%S) $*" >>"$logfile"
    echo "Error: couldn't add job for ytmsclu-daemon\n\n" >>"$logfile"
    exit
fi
