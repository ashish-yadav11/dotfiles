#!/bin/dash
case $1 in
    w)
        options="-u"
        ;;
    s)
        options="-s"
        sleep 0.5
        ;;
esac
scrot -q100 $options -e 'mv $f /home/ashish/Desktop/' &&
    notify-send -t 1000 Scrot "Screenshot captured"
