#!/bin/dash
lck8file="$XDG_RUNTIME_DIR/doublenext.1.lck"
lck9file="$XDG_RUNTIME_DIR/doublenext.2.lck"

t=0.25 # buffer to wait for the next click
dt=0.03 # >> `time flock -n <fd>`
ddt=0.003 # >> `exec <>`

exec 8<>"$lck8file" 9<>"$lck9file"

action1() {
    pactl set-sink-volume @DEFAULT_SINK@ +5%
}
action2() {
    setsid -f /home/ashish/.scripts/ytmsclu.sh
}

errorexit() {
    notify-send -u critical -t 0 dwm 'doublenext: something went wrong!'
    exit
}
run1() {
    sleep "$t"
    if flock -n 8 ; then # we read-lock 8 first to make this check foolproof
        exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
        action1
    fi
    sleep "$dt" # to prevent the edgecase where run2 just started
}
run2() {
    action2 8<&- 9<&-
    flock -w1 9 || errorexit # wait for run1 to finish sleeping
    exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
}

# `-w"$ddt"`'s are required for very rare edge-cases...
flock -w"$ddt" -s 8 || exit # exit if run2's running
flock -n 9 && { exec 8<&- 8<>"$lck8file"; run1; exit ;}
flock -w"$ddt" 8 && { run2; exit ;}
