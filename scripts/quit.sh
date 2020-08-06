#!/bin/dash
dmenu_command="dmenu -i -matching fuzzy -no-custom"
case "$(echo "Turn off Display\nLock Screen\nLogout\nReboot\nPoweroff" | $dmenu_command)" in
    "Turn off Display")
        /home/ashish/.scripts/screen.sh off
        ;;
    "Lock Screen")
        /home/ashish/.scripts/i3lock.sh
        systemctl restart timeout.service
        /home/ashish/.scripts/screen.sh off
        ;;
    Logout)
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to exit dwm?")" in
            Yes) xsetroot -name "z:quit" ;;
        esac
        ;;
    Reboot)
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to reboot the pc?")" in
            Yes) systemctl reboot ;;
        esac
        ;;
    Poweroff)
        case "$(echo "Yes\nNo" | $dmenu_command -p "Do you really want to shutdown the pc?")" in
            Yes) systemctl poweroff ;;
        esac
        ;;
esac
