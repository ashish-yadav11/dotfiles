#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -no-custom"
music_dir=/media/storage/Music
archive_dir=$music_dir/archive

path=$(realpath -s "$2")

case $path in
    "$music_dir/"*) ;;
    *) exit ;;
esac

id=${2##*(}; id=${id%)*}
echo -n "https://music.youtube.com/watch?v=$id" | xsel -ib

[ "$1" = yank ] && exit

case $(echo "Archive\nDelete" | $menu -p "$3") in
    Archive)
        base=${path#"$music_dir/"}
        case $base in
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
