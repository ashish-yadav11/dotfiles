#!/bin/sh
interface="$1"
status="$2"

[ "$status" != up ] && exit
case "$interface" in
    eno1)
        nmcli -t device show eno1 |
         grep -qFm1 "GENERAL.CONNECTION:IISER Wired Connection" &&
            systemctl --no-block restart iiserlogin.service
        ;;
    wlp5s0)
        { [ "$CONNECTION_ID" = Students ] || [ "$CONNECTION_ID" = Guest ] ;} &&
            systemctl --no-block restart iiserlogin.service
        ;;
esac
