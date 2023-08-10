#!/bin/sh
case "$2" in
    up|down)
        sigdsblocks 3
        systemctl --no-block restart goimapnotify.service
        ;;
esac
