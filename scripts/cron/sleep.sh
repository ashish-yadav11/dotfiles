#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:sleepdine"
pidfile=$XDG_RUNTIME_DIR/sleep-dine.pid

trap '[ -n "$id" ] && dunstify -C "$id"; rm -f "$pidfile"; exit' TERM
echo "$$" >"$pidfile"
id=$($notify -p -t 0 "wrap up, it's time to go to bed")
sleep 600
dunstify -C "$id"
id=""
feh -FNY /home/ashish/Pictures/sleep.jpg &
sleep 20
pkill -P "$$"
rm -f "$pidfile"
systemctl hibernate
