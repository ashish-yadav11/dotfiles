#!/bin/dash
logfile=/home/ashish/Documents/.dictionary.log
log=$(cat "$logfile")
if [ -n "$log" ] ; then
    if word=$(echo "$log" | fzf --sync) ; then
        dict "$word" >/tmp/dictionary.last
        awk -v word="$word" '
            BEGIN {print word; a = 1};
            a > 1000 {exit};
            $0 != word {print $0; a++}
        ' "$logfile" >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp "$logfile"
        less /tmp/dictionary.last
    fi
else
    notify-send -t 2000 Dictionary "History log is empty"
fi
