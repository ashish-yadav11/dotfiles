#!/bin/dash
lck7file="$XDG_RUNTIME_DIR/doublebtn3.1.lck"
lck8file="$XDG_RUNTIME_DIR/doublebtn3.2.lck"
lck9file="$XDG_RUNTIME_DIR/doublebtn3.3.lck"

t=0.3 # buffer to wait for the next click
dt=0.01 # >> `time flock -n <fd>` + ddt
ddt=0.001 # >> `exec <>`
et=2 # >> t + dt + ddt

exec 7<>"$lck7file" 8<>"$lck8file" 9<>"$lck9file"

playback() {
    case "$(playerctl status)" in
        *": active") return 0 ;;
        *) return 1 ;;
    esac
}
action1() {
    playback && pactl set-sink-volume @DEFAULT_SINK@ +1%
}
action2() {
    playback && playerctl next
}
action3() {
    playback && pactl set-sink-volume @DEFAULT_SINK@ +3%
}

errorexit() {
    notify-send -u critical -t 0 dwm 'doublebtn3: something went wrong!'
    exit

}
run1() {
    sleep "$t"
    if flock -n 8 ; then # we read-lock 8 to make this check foolproof
        exec 9<&- 8<&- # order to make sure 8's free (for read-lock) after 9
        action1
    else
        sleep "$dt" # to prevent the edgecase where run2 just started
    fi
}
run2() {
    t0="$(date +%s%N)"
    flock -w"$et" 9 || errorexit # wait for run1 to finish sleeping
    exec 9<&-
    sleep "$(echo "scale=3
        tl=(($t*10^9 - $(date +%s%N) + $t0) / 10^9)
        if (tl > 0) print tl else print 0" | bc)"
    if flock -n 7 ; then
        exec 8<&- 7<&- # order to make sure 7's free (for read-lock) after 8
        action2
    else
        sleep "$dt" # to prevent the edgecase where run3 just started
    fi
}
run3() {
    t0="$(date +%s%N)"
    action3 7<&- 8<&- 9<&-
    flock -w"$et" 8 || errorexit # wait for run2 to finish sleeping
    exec 8<&-
    sleep "$(echo "scale=3
        tl=(($t*10^9 - $(date +%s%N) + $t0) / 10^9)
        if (tl > 0) print tl else print 0" | bc)"
}

# `-w"$ddt"`'s are required for very rare edge-cases...
if ! flock -w"$ddt" 7 ; then # run3's running
    flock -w"$dt" -s 7 || errorexit
    action1 7<&- 8<&- 9<&-
    sleep "$t"
    exit
else
    flock -s 7
fi
if flock -w"$ddt" -s 8 ; then # run2's not running
    flock -n 9 && { exec 8<&- 7<&- 8<>"$lck8file"; run1; exit ;}
    flock -w"$ddt" 8 && { exec 7<&- 7<>"$lck7file"; run2; exit ;}
fi
run3
