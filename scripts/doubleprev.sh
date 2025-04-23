#!/bin/dash
lck1file="/tmp/doubleprev.1.lck"
lck2file="/tmp/doubleprev.2.lck"
dt=0.24
ddt=0.01

exec 8<>"$lck1file" 9<>"$lck2file"

action1() {
    pactl set-sink-volume @DEFAULT_SINK@ -5%
}
action2() {
    sigdwm "scrt i 2"
}

run1() {
    sleep "$dt"
    if flock -ns 8 ; then
        #EDGECASE1
        exec 9<&- 8<&- # to make sure 9 is always free if 8 is free
        action1
    fi
}
run2() {
    action2 8<&- 9<&-
    flock -w"$dt" 9 # wait for run1 to finish sleeping
}

if flock -w"$ddt" 8 ; then # `-w` to handle #EDGECASE2,3
    if flock -n 9 ; then
        #EDGECASE2
        exec 8<&- 8<>"$lck1file"
        run1
    else
        run2
    fi
elif flock -ns 8 ; then
    #EDGECASE3
    exec 8<&- 8<>"$lck1file"
    flock -w"$ddt" 9 && { run1; exit ;} # `-w` to handle EDGECASE1
    flock -w"$ddt" 8 && { run2; exit ;} # `-w` to handle EDGECASE2
fi
