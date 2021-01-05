#!/bin/dash
time=$(date +%H%M)
if [ "$time" -lt 0119 ] || [ "$time" -gt 0121 ] ; then
    exit
fi
trap '[ -n "$id" ] && dunstify -C "$id"; rm -f /tmp/sleep_dine.pid; exit' TERM
echo "$$" >/tmp/sleep_dine.pid
id=$(dunstify -p -t 0 "wrap up, it's time to go to bed")
sleep 600
dunstify -C "$id"
id=""
feh -FNY /home/ashish/Pictures/sleep.jpg &
sleep 20
pkill -P "$$"
rm -f /tmp/sleep_dine.pid
systemctl hibernate
