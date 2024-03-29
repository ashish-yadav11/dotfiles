#!/bin/dash
hotspot="sudo /home/ashish/.scripts/hotspot.sh"
notify="notify-send -h string:x-canonical-private-synchronous:hotspot"

if [ -n "$($hotspot list-running)" ] ; then
    $hotspot terminate
else
    case "$(rfkill -nro TYPE,SOFT,HARD)" in
        *"wlan blocked"*)
            $notify -t 1000 Hotspot "Wifi is soft blocked"
            exit
            ;;
        *"wlan unblocked blocked"*)
            $notify -t 1000 Hotspot "Wifi is hard blocked"
            exit
            ;;
    esac
    $hotspot initiate ||
        $notify -u critical Hotspot "Some error occured in initiating hotspot!"
fi
