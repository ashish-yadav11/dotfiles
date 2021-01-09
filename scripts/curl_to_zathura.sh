#!/bin/dash
dmenu="dmenu -i -matching fuzzy -no-custom"

case $1 in
    selection)
        url=$(xsel -ob)
        if [ -z "$url" ] ; then
            notify-send -t 2000 "curl to zathura" "Nothing in clipboard"
            exit
        fi
        ;;
    *)
        url=$(yad --title="curl to zathura" --image=zathura --no-buttons --entry \
                  --text="curl URL to zathura" --entry-label="URL:")
        [ -z "$url" ] && exit
        ;;
esac
case $(echo "Yes\nNo" | $dmenu -p "curl $url to zathura?") in
    Yes) curl -sL "$url" | zathura - ;;
esac
