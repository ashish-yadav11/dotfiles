#!/bin/dash
lck1file="$XDG_RUNTIME_DIR/doubleprev.1.lck"
lck2file="$XDG_RUNTIME_DIR/doubleprev.2.lck"
dt=0.25
ddt=0.003

exec 8<>"$lck1file" 9<>"$lck2file"

action1() {
    pactl set-sink-volume @DEFAULT_SINK@ -5%
}
action2() {
    sigdwm "scrt i 2"
}

run1() {
    sleep "$dt"
    if flock -n 8 ; then # we read-lock 8 first to make this check foolproof
        exec 9<&- 8<&- # order to make sure 9 is free before 8 is free
        action1
    fi
}
run2() {
    action2 8<&- 9<&-
    flock -w"$dt" 9 # wait for run1 to finish sleeping
    exec 9<&- 8<&- # order to make sure 9 is free before 8 is free
}

# `-w`'s are required for very rare edge-cases...
flock -w"$ddt" -s 8 || exit
flock -w"$ddt" 9 && { exec 8<&- 8<>"$lck1file"; run1; exit ;}
flock -w"$ddt" 8 && { run2; exit ;}
