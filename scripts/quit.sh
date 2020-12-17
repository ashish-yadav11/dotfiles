#!/bin/dash
dmenu="dmenu -i -matching fuzzy -no-custom"
i3lock=/home/ashish/.scripts/i3lock.sh
screen=/home/ashish/.scripts/screen.sh

case $(echo "Turn off Display\nLock Screen\nRestart dwm\nExit dwm\nReboot\nShutdown" | $dmenu -p Quit) in
    "Turn off Display")
        $screen off
        systemctl stop timeout.service
        while : ; do
            read -r state </proc/acpi/button/lid/LID/state
            case $state in *open) break ;; esac
            sleep 10
        done
        systemctl start timeout.service
        ;;
    "Lock Screen")
        $i3lock
        systemctl restart timeout.service
        $screen off
        ;;
    "Restart dwm")
        case $(echo "Yes\nNo" | $dmenu -p "Do you really want to restart dwm?") in
            Yes)
                if [ "$(pidof dwm | wc -w)" = 1 ] || [ "$DISPLAY" = :0 ] ; then
                    killall nm-applet
                    sigdwm "quit i 1"
                    exec nm-applet
                else
                    sigdwm "quit i 1"
                fi
                ;;
        esac
        ;;
    "Exit dwm")
        case $(echo "Yes\nNo" | $dmenu -p "Do you really want to exit dwm?") in
            Yes)
                sigdwm "quit i 0"
                ;;
        esac
        ;;
    Reboot)
        case $(echo "Yes\nNo" | $dmenu -p "Do you really want to reboot the pc?") in
            Yes)
                systemctl reboot
                ;;
        esac
        ;;
    Shutdown)
        case $(echo "Yes\nNo" | $dmenu -p "Do you really want to shutdown the pc?") in
            Yes)
                systemctl poweroff
                ;;
        esac
        ;;
esac
