#!/bin/dash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

case "$(echo "Yes\nNo" | menu -p "Launch $1?")" in
    Yes)
        shift
        exec "$@"
        ;;
esac
