#!/bin/ksh
notify="dunstify -h string:x-canonical-private-synchronous:inhibitsuspend -h int:transient:1"

if read -r PID </tmp/inhibitsuspend.pid && rkill "$PID" ; then
    $notify -t 1000 "System will now sleep normally on closing the lid"
    exit
fi

trap 'rm -f /tmp/inhibitsuspend.pid' EXIT
echo $$ >/tmp/inhibitsuspend.pid

id=$($notify -p -t 15000 "System will lock without sleeping if lid is closed within next 15 seconds")
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    state=${state##* }
    if [[ $state == closed ]] ; then
        dunstify -C "$id"
        /home/ashish/.scripts/i3lock.sh
        systemctl restart timeout.service
        /home/ashish/.scripts/screen.sh off
        while [[ $state == closed ]] ; do
            sleep 1
            read -r state </proc/acpi/button/lid/LID/state
            state=${state##* }
        done
        sleep 1
        break
    fi
done
