#!/bin/dash
sleep 60
time=$(date +%H%M)
if [ "$time" -gt 2051 ] || [ "$time" -lt 2049 ] ; then
    exit 0
fi
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export DISPLAY=":0"
/home/ashish/.local/bin/sigdsblocks 10 # update time in status
echo "$$" >/tmp/sleep_dine.pid
notify-send -t 600000 "wrap up, it's time for dinner"
sleep 600
/home/ashish/.local/bin/sigdsblocks 10 # update time in status
feh -FNY /home/ashish/Pictures/dine.png &
sleep 20
pkill -P "$$"
rm -f /tmp/sleep_dine.pid
systemctl hibernate
