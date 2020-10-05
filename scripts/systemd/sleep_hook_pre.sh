#!/bin/dash
read -r PID 2>/dev/null </tmp/sleep_dine.pid && rkill "$PID"
sudo /home/ashish/.scripts/hotspot.sh terminate
