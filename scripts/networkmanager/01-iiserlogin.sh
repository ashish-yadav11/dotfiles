#!/bin/dash
[ "$1" = eno1 ] || exit
case "$2" in
    up) systemctl restart iiserlogin.service ;;
    down) systemctl stop iiserlogin.service ;;
esac
