#!/bin/dash
iiserlogin=/home/ashish/.scripts/iiserlogin.sh

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
[ "$1" = eno1 ] && [ "$2" = up ] && su ashish -s /usr/bin/dash $iiserlogin
