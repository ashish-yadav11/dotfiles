#!/bin/ksh
notify-send -t 15000 "System will lock without sleeping if lid is closed within next 15 seconds"
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    state=${state##* }
    if [[ $state == closed ]] ; then
        /home/ashish/.scripts/i3lock.sh
        systemctl restart timeout.service
        /home/ashish/.scripts/screen.sh off
        while [[ $state == closed ]] ; do
            sleep 2
            read -r state </proc/acpi/button/lid/LID/state
            state=${state##* }
        done
        sleep 2
    fi
done
notify-send -t 500 "System will now sleep normally"
