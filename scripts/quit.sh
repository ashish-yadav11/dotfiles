#!/bin/dash
dmenu="dmenu -i -matching fuzzy -no-custom"

case $(echo "Turn off Display\nLock Screen\nRestart dwm\nExit dwm\nReboot\nShutdown" | $dmenu -p Quit) in
    "Turn off Display")
        screen off
        systemctl stop timeout.service
        while [ "$(xset -q | awk '$1=="Monitor" && $2=="is" {print $3; exit}')" = Off ] ; do
            sleep 10
        done
        systemctl start timeout.service
        ;;
    "Lock Screen")
        systemctl start lock.service
        screen off
        ;;
    "Restart dwm")
        case $(echo "Yes\nNo" | $dmenu -p "Do you really want to restart dwm?") in
            Yes)
                if PID=$(pidof -s /usr/bin/nm-applet) ; then
                    dpy=$(tr '\0' '\n' <"/proc/$PID/environ" | grep '^DISPLAY=')
                    if [ "${dpy#DISPLAY=}" = "$DISPLAY" ] ; then
                        killall nm-applet
                        sigdwm "quit i 1"
                        exec nm-applet
                    fi
                fi
                sigdwm "quit i 1"
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
