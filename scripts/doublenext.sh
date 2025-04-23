#!/bin/dash
lck1file="/tmp/doublenext.1.lck"
lck2file="/tmp/doublenext.2.lck"
dt=0.24
ddt=0.01

exec 8<>"$lck1file" 9<>"$lck2file"

action1() {
    pactl set-sink-volume @DEFAULT_SINK@ +5%
}
action2() {
    setsid -f /home/ashish/.scripts/ytmsclu.sh
}

run1() {
    sleep "$dt"
    if flock -ns 8 ; then
        #EDGE-CASE1
        exec 9<&- 8<&- # to make sure 9 is always free if 8 is free
        action1
    fi
}
run2() {
    action2 8<&- 9<&-
    flock -w"$dt" 9 # wait for run1 to finish sleeping
}

if flock -w"$ddt" 8 ; then # `-w` to handle #EDGE-CASE2
    if flock -n 9 ; then
        #EDGE-CASE2
        exec 8<&- 8<>"$lck1file"
        { run1; exit ;}
    else
        { run2; exit ;}
    fi
elif flock -ns 8 ; then
    #EDGE-CASE2
    exec 8<&- 8<>"$lck1file"
    flock -w"$ddt" 9 && { run1; exit ;} # `-w` to handle EDGE-CASE1
else
    exit
fi
