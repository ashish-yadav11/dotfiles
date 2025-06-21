#!/bin/dash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

name="$1"
shift

# if minimized to systray don't ask
case "$name" in
    Signal) pidof -sq signal-desktop && exec "$@" ;;
    Telegram) pidof -sq Telegram && exec "$@" ;;
esac

case "$(echo "Yes\nNo" | menu -p "Launch $name?")" in
    Yes) exec "$@" ;;
esac
