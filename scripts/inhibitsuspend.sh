#!/bin/bash
notify="dunstify -h string:x-canonical-private-synchronous:inhibitsuspend -h int:transient:1"
pidfileroot="$XDG_RUNTIME_DIR/inhibitsuspend"

if [[ "$1" == lock ]] ; then
    s=1 o=0
    notification="System will lock without sleeping if lid is closed within next 15 seconds"
    lock=1
else
    s=0 o=1
    notification="System will not sleep if lid is closed within next 15 seconds"
fi

read -r PIDo 2>/dev/null <"$pidfileroot.$o.pid" && kill "$PIDo"
if read -r PIDs 2>/dev/null <"$pidfileroot.$s.pid" && kill "$PIDs" ; then
    $notify -t 2000 "System will now sleep normally on closing the lid"
    exit
fi

trap 'rm -f "$pidfileroot"'".$s."'pid' EXIT
echo "$$" >"$pidfileroot.$s.pid"

id="$($notify -p -t 0 "$notification")"
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    if [[ "$state" == *closed ]] ; then
        dunstify -C "$id"
        [[ -n "$lock" ]] && systemctl start lock.service
        screen off
        while [[ "$state" == *closed ]] ; do
            sleep 2
            read -r state </proc/acpi/button/lid/LID/state
        done
        exit
    fi
done
$notify -t 2000 "System will now sleep normally on closing the lid"
