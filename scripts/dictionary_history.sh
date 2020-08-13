#!/bin/dash
log=$(tac /home/ashish/Documents/.dictionary.log)
if [ -n "$log" ] ; then
    word=$(echo "$log" | fzf --sync)
    [ -n "$word" ] && dict "$word" >/tmp/dictionary.last
    termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last"
    echo "$word" >>/home/ashish/Documents/.dictionary.log
    awk '!visited[$0]++' /home/ashish/Documents/.dictionary.log | tail -10000 >/tmp/dictionary.log.temp
    mv /tmp/dictionary.log.temp /home/ashish/Documents/.dictionary.log
else
    notify-send -t 2000 "Dictionary" "History log is empty"
fi
