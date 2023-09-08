#!/bin/sh
case "$2" in
    up|down)
        systemctl --no-block restart goimapnotify.service
        ;;
esac
