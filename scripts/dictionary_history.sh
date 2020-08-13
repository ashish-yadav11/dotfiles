#!/bin/dash
log=$(cat /home/ashish/Documents/.dictionary.log)
if [ -n "$log" ] ; then
    if word=$(echo "$log" | fzf --sync) ; then
        dict "$word" >/tmp/dictionary.last
        less /tmp/dictionary.last
        echo "$word" >>/home/ashish/Documents/.dictionary.log
        awk '!visited[$0]++' /home/ashish/Documents/.dictionary.log | tail -10000 >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp /home/ashish/Documents/.dictionary.log
    fi
else
    notify-send -t 2000 "Dictionary" "History log is empty"
fi
