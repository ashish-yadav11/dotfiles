#!/bin/dash
time=$(date +%H%M)
if [ "$time" -lt 2049 ] || [ "$time" -gt 2051 ] ; then
    exit
fi
trap '[ -n "$id" ] && dunstify -C "$id"; rm -f /tmp/sleep_dine.pid; exit' TERM
echo "$$" >/tmp/sleep_dine.pid
id=$(dunstify -p -t 0 "wrap up, it's time for dinner")
sleep 600
dunstify -C "$id"
id=""
time=$(date +%H%M)
if [ "$time" -lt 2059 ] || [ "$time" -gt 2101 ] ; then
    rm -f /tmp/sleep_dine.pid
    exit
fi
feh -FNY /home/ashish/Pictures/dine.png &
sleep 20
pkill -P "$$"
rm -f /tmp/sleep_dine.pid
systemctl hibernate
