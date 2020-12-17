#!/bin/bash
notify="dunstify -h string:x-canonical-private-synchronous:inhibitsuspend -h int:transient:1"
screen=/home/ashish/.scripts/screen.sh

read -r PID1 </tmp/inhibitsuspend1.pid && kill "$PID1"
if read -r PID0 </tmp/inhibitsuspend0.pid && kill "$PID0" ; then
    $notify -t 2000 "System will now sleep normally on closing the lid"
    exit
fi

trap 'rm -f /tmp/inhibitsuspend0.pid' EXIT
echo "$$" >/tmp/inhibitsuspend0.pid

id=$($notify -p -t 0 "System will not sleep if lid is closed within next 15 seconds")
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    if [[ $state == *closed ]] ; then
        dunstify -C "$id"
        systemctl stop timeout.service
        $screen off
        while [[ $state == *closed ]] ; do
            sleep 2
            read -r state </proc/acpi/button/lid/LID/state
        done
        systemctl start timeout.service
        exit
    fi
done
$notify -t 2000 "System will now sleep normally on closing the lid"
