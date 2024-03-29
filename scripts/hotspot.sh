#!/bin/dash
wifi_interface=wlp5s0

case "$1" in
    initiate)
        fallback_interface=eno1

        nmcli device disconnect "$wifi_interface" 2>/dev/null
        active_interface="$(nmcli -t -f DEVICE connection show --active)"
        newline='
'
        active_interface="${active_interface%%"$newline"*}"
        trap 'sigdsblocks 4 0; exit 0' HUP INT TERM
        sigdsblocks 4 1
        create_ap "$wifi_interface" "${active_interface:-"$fallback_interface"}" hp 98761234
        status="$?"
        sigdsblocks 4 0
        exit "$status"
        ;;
    terminate)
        create_ap --stop "$wifi_interface"
        ;;
    list-running)
        create_ap --list-running
        ;;
    fix-unmanaged)
        [ -z "$(create_ap --list-running)" ] && create_ap --fix-unmanaged
        ;;
    *)
        echo "Usage: $0 initiate|terminate|list-running|fix-unmanaged"
        ;;
esac
