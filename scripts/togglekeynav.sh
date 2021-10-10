#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:keynav"

if killall keynav ; then
    $notify -t 1000 'keynav stopped'
else
    keynav daemonize
    $notify -t 1000 'keynav started'
fi
