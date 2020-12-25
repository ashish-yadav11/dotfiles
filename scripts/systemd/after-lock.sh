#!/bin/dash
PID=$(pidof -s /usr/bin/i3lock) && tail --pid="$PID" -f /dev/null
notify-send DUNST_COMMAND_RESUME
systemctl restart timeout.service
