#!/bin/dash
exec >/dev/null 2>&1

case "$1" in
    pre)
        rundir=/run/user/1000
        hotspot=/home/ashish/.scripts/hotspot.sh

        read -r PID <"$rundir/sleep-dine.pid" && kill "$PID" $(pgrep -P "$PID")
        [ -s "$rundir/pomodoro.nid" ] ||
            { read -r PID <"$rundir/pomodoro.pid" && kill "$PID" $(pgrep -P "$PID") ;}

        $hotspot terminate
        ;;
    post)
        export DISPLAY=:0
        export XAUTHORITY=/home/ashish/.Xauthority

        sigdsblocks 1 # calendar
        sigdsblocks 2 # volume
        sigdsblocks 5 # battery
        sigdsblocks 6 # cpu
        sigdsblocks 7 # ram

        time="$(date +%H%M)"
        if [ "$time" -ge 2200 ] || [ "$time" -lt 0600 ] ; then
            redshift -PO 4500
        else
            redshift -x
        fi

        read -r PID </var/run/atd.pid && kill -HUP "$PID"
        ntping
        ;;
esac
