#!/bin/dash
case $(echo "Root\nFocused window without border\nFocused window with border\nSelection" |
            dmenu -i -matching fuzzy -no-custom -p Scrot) in
    Root)
        ;;
    "Focused window without border")
        options="-u"
        ;;
    "Focused window with border")
        options="-ub"
        ;;
    Selection)
        options="-s"
        ;;
    *)
        exit
        ;;
esac

scrot -q100 $options -e 'mv $f /home/ashish/Desktop/' &&
    notify-send -t 1000 Scrot "Screenshot captured"
