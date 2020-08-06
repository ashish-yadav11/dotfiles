#!/bin/dash
case "$(xdotool getactivewindow getwindowname)" in
    *Brave | *"Google Chrome")
        case "$1" in
            u) xdotool key F6 ;;
            i) xdotool key Shift+F6 ;;
        esac
        ;;
esac
