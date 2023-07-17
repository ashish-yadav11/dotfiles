#!/bin/dash
menu="dmenu -i -matching fuzzy -no-custom"
music_dir=/media/storage/Music

path="$(realpath -s "$2")"

case "$path" in
    "$music_dir/"*)
        idp="${2##*(}"
        if [ "$idp" != "$2" ] ; then
            id="${idp%)*}"
            [ "$id" != "$idp" ] &&
                echo -n "https://music.youtube.com/watch?v=$id" | xsel -ib
        fi
        [ "$1" = yank ] && exit
        ;;
    *)
        [ "$1" != yank ] && exit
        if [ "$idp" != "$2" ] ; then
            id="${idp%)*}"
            [ "$id" != "$idp" ] &&
                echo -n "https://www.youtube.com/watch?v=$id" | xsel -ib
        fi
        exit
        ;;
esac

winid="$(xdotool search --classname scratch-st | head -n1)"
if [ -z "$winid" ] ; then
    notify-send -t 1500 ytmsclu "Scratch terminal not open!"
    exit
fi
filename="${path##*/}"
case "$(echo "Archive\nDelete\nLike" | $menu -p "$filename")" in
    Archive)
        base="${path#"$music_dir/"}"
        case "$base" in
            */*)
                notify-send -u critical -t 3000 mpv "Current song not in the root Music folder!"
                exit
                ;;
        esac
        xdotool key --window "$winid" u l k l Enter
        ;;
    Delete)
        xdotool key --window "$winid" u l k l space minus r Enter
        ;;
    Like)
        xdotool key --window "$winid" d l k l Enter
        ;;
esac
