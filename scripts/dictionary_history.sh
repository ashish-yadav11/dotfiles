#!/bin/dash
log=$(fzf --sync --tac </home/ashish/Documents/.dictionary.log)
if [ -n "$log" ] ; then
    dict "$log" | less
else
    notify-send -t 2000 "Dictionary" "Log is empty"
fi
