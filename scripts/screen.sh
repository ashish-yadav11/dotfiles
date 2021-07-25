#!/bin/dash
case "$1" in
    standby|suspend|off)
        sleep 1
        xset dpms force "$1"
        ;;
    *)
        echo "Usage: $0 standby|suspend|off"
        ;;
esac
