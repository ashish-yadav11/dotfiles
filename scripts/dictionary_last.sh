#!/bin/dash
if [ -f /tmp/dictionary.last ] ; then
    termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last"
else
    notify-send -t 2000 "Dictionary" "Last word not available"
fi
