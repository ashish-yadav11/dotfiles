#!/bin/dash
log=$(tac /home/ashish/Documents/.dictionary.log)
if [ -n "$log" ] ; then
    word=$(echo "$log" | fzf --sync)
    [ -n "$word" ] && dict "$word" | less
else
    notify-send -t 2000 "Dictionary" "History log is empty"
fi
