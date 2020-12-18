#!/bin/dash
trap 'rm -f /tmp/sleep_dine.pid; exit' TERM
echo "$$" >/tmp/sleep_dine.pid
id=$(dunstify -p -t 0 "wrap up, it's time to go to bed")
sleep 600
dunstify -C "$id"
time=$(date +%H%S)
if [ "$time" -lt 0129 ] || [ "$time" -gt 0131 ] ; then
    rm -f /tmp/sleep_dine.pid
    exit
fi
feh -FNY /home/ashish/Pictures/sleep.jpg &
sleep 20
pkill -P "$$"
rm -f /tmp/sleep_dine.pid
systemctl hibernate
