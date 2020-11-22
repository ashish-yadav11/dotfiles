#!/bin/ksh
i3lock=/home/ashish/.scripts/i3lock.sh
notify="dunstify -h string:x-canonical-private-synchronous:inhibitsuspend -h int:transient:1"
screen=/home/ashish/.scripts/screen.sh

if read -r PID </tmp/inhibitsuspend.pid && rkill "$PID" ; then
    $notify -t 2000 "System will now sleep normally on closing the lid"
    exit
fi

trap 'rm -f /tmp/inhibitsuspend.pid' EXIT
echo $$ >/tmp/inhibitsuspend.pid

id=$($notify -p -t 0 "System will lock without sleeping if lid is closed within next 15 seconds")
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    state=${state##* }
    if [[ $state == closed ]] ; then
        dunstify -C "$id"
        $i3lock
        systemctl restart timeout.service
        $screen off
        while [[ $state == closed ]] ; do
            sleep 1
            read -r state </proc/acpi/button/lid/LID/state
            state=${state##* }
        done
        sleep 1
        exit
    fi
done
$notify -t 2000 "System will now sleep normally on closing the lid"
