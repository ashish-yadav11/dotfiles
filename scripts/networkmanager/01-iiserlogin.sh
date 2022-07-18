#!/bin/dash
interface="$1"
status="$2"

possibly_connected_to_iiser() {
    [ "$interface" = eno1 ] ||
        { [ "$interface" = wlp5s0 ] && [ "$CONNECTION_ID" = Students ] ;}
}

case "$status" in
    down)
        possibly_connected_to_iiser && systemctl stop iiserlogin.service
        ;;
    dhcp4-change|up)
        [ "$DHCP4_DOMAIN_NAME" = "iiserpune.ac.in" ] &&
            possibly_connected_to_iiser && systemctl restart iiserlogin.service
        ;;
esac
