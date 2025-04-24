#!/bin/dash
lck1file="$XDG_RUNTIME_DIR/doublenext.1.lck"
lck2file="$XDG_RUNTIME_DIR/doublenext.2.lck"
dt=0.25
ddt=0.003

exec 8<>"$lck1file" 9<>"$lck2file"

action1() {
    pactl set-sink-volume @DEFAULT_SINK@ +5%
}
action2() {
    setsid -f /home/ashish/.scripts/ytmsclu.sh
}

run1() {
    sleep "$dt"
    if flock -n 8 ; then # we read-lock 8 first to make this check foolproof
        exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
        action1
    fi
}
run2() {
    action2 8<&- 9<&-
    if ! flock -w1 9 ; then # wait for run1 to finish sleeping
        notify-send -u critical -t 0 dwm 'doublenext: something went wrong!'
        exit
    fi
    exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
}

# `-w"$ddt"`'s are required for very rare edge-cases...
flock -w"$ddt" -s 8 || exit # exit if run2's running
flock -n 9 && { exec 8<&- 8<>"$lck1file"; run1; exit ;}
flock -w"$ddt" 8 && { run2; exit ;}
