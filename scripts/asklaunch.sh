#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -no-custom"

case $(echo "Yes\nNo" | $menu -p "Launch $1") in
    Yes)
        shift
        exec "$@"
        ;;
esac
