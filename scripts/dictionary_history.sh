#!/bin/dash
logfile=/home/ashish/Documents/.dictionary.log
log=$(cat "$logfile")
if [ -n "$log" ] ; then
    if word=$(echo "$log" | fzf --sync) ; then
        dict "$word" >/tmp/dictionary.last
        sed -e "1i\\$word" -e "/^$word$/d" "$logfile" |
            head -10000 >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp "$logfile"
        less /tmp/dictionary.last
    fi
else
    notify-send -t 2000 Dictionary "History log is empty"
fi
