#!/bin/dash
trap 'rm -f /tmp/sleep_dine.pid; exit' TERM
echo "$$" >/tmp/sleep_dine.pid
id=$(dunstify -p -t 0 "wrap up, it's time for dinner")
sleep 600
dunstify -C "$id"
feh -FNY /home/ashish/Pictures/dine.png &
sleep 20
pkill -P "$$"
rm -f /tmp/sleep_dine.pid
systemctl hibernate
