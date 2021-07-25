#!/bin/dash
if [ -f /tmp/dictionary.last ] ; then
    st -n floating-st -t Dictionary -e less /tmp/dictionary.last
else
    notify-send -t 2000 Dictionary "Last word not available"
fi
