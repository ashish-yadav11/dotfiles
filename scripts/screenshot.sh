#!/bin/dash
case $(echo "Root\nFocused window\nSelection" | dmenu -i -matching fuzzy -no-custom -p Scrot) in
    Root)
        ;;
    "Focused window")
        options="-u"
        ;;
    Selection)
        options="-s"
        ;;
    *)
        exit
        ;;
esac

scrot -q100 $options '/home/ashish/Pictures/screenshots/%Y-%m-%d-%H%M%S_$wx$h.png' &&
    notify-send -t 1000 Scrot "Screenshot captured"
