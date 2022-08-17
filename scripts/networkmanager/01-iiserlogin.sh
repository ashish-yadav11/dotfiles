#!/bin/dash
interface="$1"
status="$2"

if [ "$status" = down ] ; then
    possibly_connected_to_iiser && systemctl stop iiserlogin.service
elif [ "$interface" = eno1 ] ; then
    if [ "$status" = up ] || [ "$status" = "dhcp4-change" ] ; then
        systemctl restart iiserlogin.service
    fi
elif [ "$status" = up ] && [ "$interface" = wlp5s0 ] &&
     [ "$CONNECTION_ID" = Students ] ; then
    systemctl restart iiserlogin.service
fi
