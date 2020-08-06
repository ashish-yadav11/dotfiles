#!/bin/dash
if read -r PID 2>/dev/null </tmp/sleep_dine.pid ; then
    rm -f /tmp/sleep_dine.pid
    [ -n "$PID" ] && rkill "$PID"
fi
sudo /home/ashish/.scripts/hotspot.sh terminate
