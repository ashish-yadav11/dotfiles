#!/bin/dash
time=$(date +%H%M)
{ [ "$time" -gt 2051 ] || [ "$time" -lt 2049 ] ;} && exit 0

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
trap 'rm -f /tmp/sleep_dine.pid; exit' HUP INT TERM
echo $$ >/tmp/sleep_dine.pid
notify-send -t 600000 "wrap up, it's time for dinner"
sleep 600
feh -FNY /home/ashish/Pictures/dine.png &
sleep 20
pkill -P $$
rm -f /tmp/sleep_dine.pid
systemctl hibernate
