#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:sleepdine"
pidfile=/run/user/1000/sleep-dine.pid

trap '[ -n "$id" ] && dunstify -C "$id"; rm -f "$pidfile"; exit' TERM
echo "$$" >"$pidfile"
id=$($notify -p -t 0 "wrap up, it's time for dinner")
sleep 600
dunstify -C "$id"
id=""
feh -FNY /home/ashish/Pictures/dine.png &
sleep 20
pkill -P "$$"
rm -f "$pidfile"
systemctl hibernate
