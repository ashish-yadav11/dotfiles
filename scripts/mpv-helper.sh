#!/bin/dash
menu="dmenu -i -matching fuzzy -no-custom"
music_dir=/media/storage/Music
archive_dir="$music_dir/archive"

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

case "$(echo "Archive\nDelete" | $menu -p "$3")" in
    Archive)
        base="${path#"$music_dir/"}"
        case "$base" in
            */*)
                notify-send -u critical -t 3000 mpv "Current song not in the root Music folder!"
                exit
                ;;
        esac
        mv -f "$path" "$archive_dir/$base"
        ;;
    Delete)
        rm -f "$path"
        ;;
esac
