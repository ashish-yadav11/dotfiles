#!/bin/dash
lck1file="/tmp/doubleclick.1.lck"
lck2file="/tmp/doubleclick.2.lck"
lck3file="/tmp/doubleclick.3.lck"
dt=0.25
ddt=0.025 # should be considerably > `time flock <>`

exec 7<>"$lck1file" 8<>"$lck2file" 9<>"$lck3file"

action1() {
    playerctl play-pause
}
action2() {
    playerctl next
}

flock -w"$ddt" 9 || exit
if flock -n 7 ; then
    exec 9<&-
    sleep "$dt"
    flock -w"$ddt" 9
    # the -w"$ddt" gymnastics is to prevent the following check to happen after
    # `if flock -n 7` fails but before the `elif flock -n 8` runs in run2
    if flock -n 8 ; then
        exec 7<&-
        exec 8<&- 9<&- # free 7 before 9
        action1
    fi
elif flock -n 8 ; then
    exec 9<&-
    action2
    flock -w"$dt" 7 # wait for run1 to finish sleeping
fi
