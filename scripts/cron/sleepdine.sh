#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:sleepdine"
pidfile=/run/user/1000/sleep-dine.pid

if [ "$1" = sleep ] ; then
    notif="wrap up, it's time to go to bed"
else
    notif="wrap up, it's time for dinner"
fi

trap '[ -n "$id" ] && dunstify -C "$id"; rm -f "$pidfile"; exit' TERM
echo "$$" >"$pidfile"
id="$($notify -p -t 0 "$notif")"
sleep 600
dunstify -C "$id"
id=""
feh -FNY "/home/ashish/Pictures/$1.jpg" &
sleep 20
pkill -P "$$"
rm -f "$pidfile"
systemctl suspend
