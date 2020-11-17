#!/bin/dash
usage() {
    echo "Usage: nt <time in minutes> <notification body>"
    exit
}
printf %f "$1" >/dev/null 2>&1 || usage # check first argument
dt=$(echo "($1 * 60 + 0.5) / 1" | bc)
shift
[ -z "$*" ] && usage # check second argument
t0=$(date +%s)
sleep "$dt"
t1=$(date +%s)
[ "$(( t1 - t0 - dt ))" -le 1 ] && notify-send -t 0 "$*"
