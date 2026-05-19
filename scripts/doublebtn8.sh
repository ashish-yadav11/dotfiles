#!/bin/dash
script="doublebtn8"
lck7file="$XDG_RUNTIME_DIR/$script.1.lck"
lck8file="$XDG_RUNTIME_DIR/$script.2.lck"
lck9file="$XDG_RUNTIME_DIR/$script.3.lck"

t=0.4 # buffer to wait for the next click
dt=0.01 # >> `time flock -n <fd>` + ddt
ddt=0.001 # >> `exec <>`
et=2 # >> t + dt + ddt

exec 7<>"$lck7file" 8<>"$lck8file" 9<>"$lck9file"

winswitcher() {
    eval $(xdotool getmouselocation --shell)
    sigdwm "wln$1 i 0"
    if [ "$1" = c ] ; then
        awinid="$(xprop -root _NET_ACTIVE_WINDOW)"
        awinid="${awinid#*"# "}"
        index="$(wmctrl -l | gawk '
                strtonum($1) == strtonum('"$awinid"') {a = NR}
                END {if (a) print (NR - a)}')"
    else
        index=2
    fi
    xte "mousemove 1010 580"
    rofi -show window -selected-row "$index" -no-click-to-exit \
        -kb-accept-entry 'Control+m,Return,MouseExtra92,MouseExtra91,MouseExtra98' \
        -kb-cancel 'Escape,Control+g,Control+bracketleft,MouseExtra93,MouseExtra99'
    xte "mousemove $X $Y"
}

action1() {
    sigdwm "fclv i 0"
}
action2() {
    winswitcher s
}
action3() {
    sigdwm "shdv ui 0"
}

errorexit() {
    notify-send -u critical -t 0 dwm "$script: something went wrong!"
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
