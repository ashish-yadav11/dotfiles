#!/bin/ksh
if read -r PID0 </tmp/inhibitsuspend0.pid && rkill "$PID0" ; then
    dunstify -r 231219 -t 1 "System will not sleep if lid is closed within next 15 seconds"
    exit
fi
trap 'rm -f /tmp/inhibitsuspend0.pid' EXIT
echo $$ >/tmp/inhibitsuspend0.pid
read -r PID1 </tmp/inhibitsuspend1.pid && rkill "$PID1"

dunstify -r 231219 -t 15000 "System will not sleep if lid is closed within next 15 seconds"
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    state=${state##* }
    if [[ $state == closed ]] ; then
        systemctl stop timeout.service
        /home/ashish/.scripts/screen.sh off
        while [[ $state == closed ]] ; do
            sleep 1
            read -r state </proc/acpi/button/lid/LID/state
            state=${state##* }
        done
        systemctl start timeout.service
        sleep 1
        break
    fi
done
notify-send -t 500 "System will now sleep normally on closing the lid"
