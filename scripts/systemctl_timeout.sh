#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:timeout"

case $1 in
    restart)
        systemctl restart timeout.service
        $notify -t 1000 "timeout service restarted"
        ;;
    toggle)
        if systemctl -q is-active timeout.service ; then
            systemctl stop timeout.service
            $notify -t 1000 "timeout service stopped"
        else
            systemctl start timeout.service
            $notify -t 1000 "timeout service started"
        fi
        ;;
    status)
        if systemctl -q is-active timeout.service ; then
            $notify -t 1000 "timeout service is up"
        else
            $notify -t 1000 "timeout service is down"
        fi
        ;;
    *)
        echo "Usage: $0 restart|toggle|status"
        ;;
esac
