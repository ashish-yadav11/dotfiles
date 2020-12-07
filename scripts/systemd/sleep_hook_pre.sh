#!/bin/dash
hotspot=/home/ashish/.scripts/hotspot.sh

exec >/dev/null 2>&1
read -r PID </tmp/sleep_dine.pid && /usr/bin/kill -- "-$PID"
sudo $hotspot terminate
