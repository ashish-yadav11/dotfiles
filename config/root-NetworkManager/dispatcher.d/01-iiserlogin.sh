#!/bin/sh
interface="$1"
status="$2"

case "$status" in

up)
    case "$interface" in
        eno1)
            nmcli -t device show eno1 |
                grep -qFm1 "GENERAL.CONNECTION:IISER Wired Connection" &&
                    { systemctl --no-block restart iiserlogin.service; exit ;}
            ;;
        wlp5s0)
            { [ "$CONNECTION_ID" = Students ] || [ "$CONNECTION_ID" = Guest ] ;} &&
                    { systemctl --no-block restart iiserlogin.service; exit ;}
            ;;
    esac
    nmcli -t device show | grep -qFm1 "iiserpune.ac.in" ||
        systemctl --no-block stop iiserlogin.service
    ;;

down)
    nmcli -t device show | grep -qFm1 "iiserpune.ac.in" ||
        systemctl --no-block stop iiserlogin.service
    ;;

esac
