#!/bin/dash
lck7file="$XDG_RUNTIME_DIR/doubleclick.1.lck"
lck8file="$XDG_RUNTIME_DIR/doubleclick.2.lck"
lck9file="$XDG_RUNTIME_DIR/doubleclick.3.lck"
dt=0.25
ddt=0.003

exec 7<>"$lck7file" 8<>"$lck8file" 9<>"$lck9file"

action1() {
    playerctl play-pause
}
action2() {
    playerctl next
}
action3() {
    playerctl previous
}

run1() {
    sleep "$dt"
    if flock -n 8 ; then # we read-lock 8 to make this check foolproof
        exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
        action1
    fi
}
run2() {
    t0="$(date +%s%N)"
    if ! flock -w1 9 ; then # wait for run1 to finish sleeping
        notify-send -u critical -t 0 dwm 'doubleclick: something went wrong!'
        exit
    fi
    exec 9<&-
    sleep "$(echo "scale=3; ($dt*10^9 + $(date +%s%N) - $t0) / 10^9" | bc)"
    if flock -n 7 ; then # we read-lock 7 first to make this check foolproof
        exec 8<&- 7<&- # order to make sure 7's free (for read-lock) after 8
        action2
    fi
}
run3() {
    action3 7<&- 8<&- 9<&-
    if ! flock -w1 8 ; then # wait for run1 to finish sleeping
        notify-send -u critical -t 0 dwm 'doubleclick: something went wrong!'
        exit
    fi
    exec 8<&- 7<&- # order to make sure 7's free (for read-lock) after 8
}

# `-w"$ddt"`'s are required for very rare edge-cases...
flock -w"$ddt" -s 7 || exit # exit if run3's running
if flock -w"$ddt" -s 8 ; then # run2's not running
    flock -n 9 && { exec 8<&- 7<&- 8<>"$lck8file"; run1; exit ;}
    flock -w"$ddt" 8 && { exec 7<&- 7<>"$lck7file"; run2; exit ;}
    flock -w"$ddt" 7 && { run3; exit ;}
else # run2's running
    flock -w"$ddt" 7 && { run3; exit ;}
fi
