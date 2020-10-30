#!/bin/dash
logfile=/home/ashish/Documents/.dictionary.log
log=$(tac "$logfile")
if [ -n "$log" ] ; then
    if word=$(echo "$log" | fzf --sync) ; then
        dict "$word" >/tmp/dictionary.last
        less /tmp/dictionary.last
        echo "$word" >>"$logfile"
        awk '!visited[$0]++' "$logfile" | tail -10000 >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp "$logfile"
    fi
else
    notify-send -t 2000 Dictionary "History log is empty"
fi
