#!/bin/dash
case "$2" in
    up|down)
        sigdsblocks 3
        systemctl restart goimapnotify.service
        ;;
esac
