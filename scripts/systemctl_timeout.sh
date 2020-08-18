#!/bin/dash
case "$1" in
    toggle)
        if systemctl --quiet is-active timeout.service ; then
            systemctl stop timeout.service
            dunstify -r 192519 -t 1000 "systemctl" "timeout service stopped"
        else
            systemctl start timeout.service
            dunstify -r 192519 -t 1000 "systemctl" "timeout service started"
        fi
        ;;
    status)
        if systemctl --quiet is-active timeout.service ; then
            dunstify -r 192519 -t 1000 "systemctl" "timeout service is up"
        else
            dunstify -r 192519 -t 1000 "systemctl" "timeout service is down"
        fi
        ;;
    *)
        echo "Usage: $0 toggle|status"
    ;;
esac
