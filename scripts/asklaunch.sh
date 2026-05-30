#!/bin/dash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}
                     entry {enabled: false;}' \
         -kb-accept-entry 'Control+m,Return,[172],MouseExtra92,MouseExtra91,MouseExtra98' \
         -kb-cancel 'Escape,Control+g,Control+bracketleft,semicolon,[123],MouseExtra93,MouseExtra99' \
         -kb-row-down 'Down,Control+j,[122]' -no-click-to-exit \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

name="$1"
shift

# if minimized to systray don't ask
case "$name" in
    Signal) pidof -sq signal-desktop && exec "$@" ;;
    Telegram) pidof -sq Telegram && exec "$@" ;;
esac

eval $(xdotool getmouselocation --shell)
xte "mousemove 1350 50"
response="$(echo "Yes\nNo" | menu -p "Launch $name?")"
xte "mousemove $X $Y"
case "$response" in
    Yes) exec "$@" ;;
esac
