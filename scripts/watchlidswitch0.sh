#!/bin/ksh
read -r PID0 </tmp/watchlidswitch0.pid && rkill "$PID0" && exit
read -r PID1 </tmp/watchlidswitch1.pid && rkill "$PID1"
trap 'rm -f /tmp/watchlidswitch0.pid; exit' EXIT HUP INT TERM
echo "$$" >/tmp/watchlidswitch0.pid

notify-send -t 15000 "System will not sleep if lid is closed within next 15 seconds"
SECONDS=0
while (( SECONDS < 15 )) ; do
    sleep 1
    read -r state </proc/acpi/button/lid/LID/state
    state=${state##* }
    if [[ $state == closed ]] ; then
        systemctl stop timeout.service
        /home/ashish/.scripts/screen.sh off
        while [[ $state == closed ]] ; do
            sleep 2
            read -r state </proc/acpi/button/lid/LID/state
            state=${state##* }
        done
        sleep 2
    fi
done
systemctl start timeout.service
notify-send -t 500 "System will now sleep normally"
