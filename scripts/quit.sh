#!/bin/dash
dmenu_command="dmenu -i -matching fuzzy -no-custom -p quit"
case "$(echo "Turn off Display\nLock Screen\nRestart dwm\nExit dwm\nReboot\nShutdown" | $dmenu_command)" in
    "Turn off Display")
        /home/ashish/.scripts/screen.sh off
        ;;
    "Lock Screen")
        /home/ashish/.scripts/i3lock.sh
        systemctl restart timeout.service
        /home/ashish/.scripts/screen.sh off
        ;;
    "Restart dwm")
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to restart dwm?")" in
            Yes)
                rootname=$(xgetrootname)
                xsetroot -name "z:quit i 1"
                xsetroot -name "$rootname"
                ;;
        esac
        ;;
    "Exit dwm")
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to exit dwm?")" in
            Yes)
                rootname=$(xgetrootname)
                xsetroot -name "z:quit i 0"
                xsetroot -name "$rootname"
                ;;
        esac
        ;;
    Reboot)
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to reboot the pc?")" in
            Yes)
                systemctl reboot
                ;;
        esac
        ;;
    Shutdown)
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to shutdown the pc?")" in
            Yes)
                systemctl poweroff
                ;;
        esac
        ;;
esac
