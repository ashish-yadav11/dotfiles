#!/bin/bash
notify="dunstify -h string:x-canonical-private-synchronous:inhibitsuspend -h int:transient:1"

read -r PID0 </tmp/inhibitsuspend0.pid && kill "$PID0"
if read -r PID1 </tmp/inhibitsuspend1.pid && kill "$PID1" ; then
    $notify -t 2000 "System will now sleep normally on closing the lid"
    exit
fi

trap 'rm -f /tmp/inhibitsuspend1.pid' EXIT
echo "$$" >/tmp/inhibitsuspend1.pid

id=$($notify -p -t 0 "System will lock without sleeping if lid is closed within next 15 seconds")
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    if [[ $state == *closed ]] ; then
        dunstify -C "$id"
        systemctl start lock.service
        screen off
        while [[ $state == *closed ]] ; do
            sleep 2
            read -r state </proc/acpi/button/lid/LID/state
        done
        exit
    fi
done
$notify -t 2000 "System will now sleep normally on closing the lid"
