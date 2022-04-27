#!/bin/dash
interface="$1"
status="$2"

possibly_connected_to_iiser() {
    [ "$interface" = eno1 ] ||
        { [ "$interface" = wlp5s0 ] && [ "$CONNECTION_ID" = Students ] ;}
}

if [ "$status" = down ] ; then
    possibly_connected_to_iiser && systemctl stop iiserlogin.service
elif [ "$status" = up ] && [ "$DHCP4_DOMAIN_NAME" = "iiserpune.ac.in" ] ; then
    possibly_connected_to_iiser && systemctl restart iiserlogin.service
fi
