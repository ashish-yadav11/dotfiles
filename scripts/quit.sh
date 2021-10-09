#!/bin/dash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

case "$(echo "Turn off Display\nLock Screen\nRestart dwm\nExit dwm\nReboot\nShutdown\nSuspend\nHibernate" | menu -p Quit)" in
    "Turn off Display")
        screen off
        ;;
    "Lock Screen")
        systemctl start lock.service
        screen off
        ;;
    "Restart dwm")
        case "$(echo "Yes\nNo" | menu -p "Do you really want to restart dwm?")" in
            Yes)
                sigdwm "quit i 1"
                ;;
        esac
        ;;
    "Exit dwm")
        case "$(echo "Yes\nNo" | menu -p "Do you really want to exit dwm?")" in
            Yes)
                sigdwm "quit i 0"
                ;;
        esac
        ;;
    Reboot)
        case "$(echo "Yes\nNo" | menu -p "Do you really want to reboot the pc?")" in
            Yes)
                systemctl reboot
                ;;
        esac
        ;;
    Shutdown)
        case "$(echo "Yes\nNo" | menu -p "Do you really want to shutdown the pc?")" in
            Yes)
                systemctl poweroff
                ;;
        esac
        ;;
    Suspend)
        systemctl suspend
        ;;
    Hibernate)
        case "$(echo "Yes\nNo" | menu -p "Do you really want to hibernate the pc?")" in
            Yes)
                systemctl hibernate
                ;;
        esac
        ;;
esac
