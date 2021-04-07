#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -i -matching fuzzy -no-custom"

case $(echo "Turn off Display\nLock Screen\nRestart dwm\nExit dwm\nReboot\nShutdown" | $menu -p Quit) in
    "Turn off Display")
        screen off
        ;;
    "Lock Screen")
        systemctl start lock.service
        screen off
        ;;
    "Restart dwm")
        case $(echo "Yes\nNo" | $menu -p "Do you really want to restart dwm?") in
            Yes)
                sigdwm "quit i 1"
                ;;
        esac
        ;;
    "Exit dwm")
        case $(echo "Yes\nNo" | $menu -p "Do you really want to exit dwm?") in
            Yes)
                sigdwm "quit i 0"
                ;;
        esac
        ;;
    Reboot)
        case $(echo "Yes\nNo" | $menu -p "Do you really want to reboot the pc?") in
            Yes)
                systemctl reboot
                ;;
        esac
        ;;
    Shutdown)
        case $(echo "Yes\nNo" | $menu -p "Do you really want to shutdown the pc?") in
            Yes)
                systemctl poweroff
                ;;
        esac
        ;;
esac
