#!/bin/dash
exec >/dev/null 2>&1
read -r PID </tmp/sleep_dine.pid && rkill "$PID"
sudo /home/ashish/.scripts/hotspot.sh terminate
