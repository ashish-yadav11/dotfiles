#!/bin/dash
interface="$1"
status="$2"

[ "$status" != up ] && exit
case "$interface" in
    eno1)
        nmcli -t device show eno1 |
         grep -qFm1 "IP4.DOMAIN[1]:iiserpune.ac.in" &&
            systemctl restart iiserlogin.service
        ;;
    wlp5s0)
        [ "$CONNECTION_ID" = Students ] && nmcli -t device show wlp5s0 |
         grep -qFm1 "IP4.DOMAIN[1]:iiserpune.ac.in" &&
            systemctl restart iiserlogin.service
        ;;
esac
