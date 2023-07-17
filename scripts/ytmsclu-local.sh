#!/bin/dash
musicdir=/media/storage/Music
menu="dmenu -i -matching fuzzy -no-custom"
ytmsclu_addjob="/home/ashish/.scripts/ytmsclu-addjob.sh"


path="$(realpath -s "$2")"
filename="${path##*/}"

case "$path" in
    "$musicdir/"*)
        idp="${filename##*(}"
        id="${idp%)*}"
        if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
            url="https://music.youtube.com/watch?v=$id"
            echo -n "$url" | xsel -ib
        else
            notify-send -u critical -t 0 ytmsclu "Seomthing is wrong!\n'$path'"
            exit
        fi
        [ "$1" = yank ] && exit
        title="${filename%" ($id)*"} [$id]"
        case "$path" in
            "$musicdir/archive/"*) menuarg="Like\nUnlike\nRemove" ;;
                                *) menuarg="Unlike\nRemove\nLike" ;;
        esac
        case "$(echo "$menuarg" | $menu -p "$title")" in
            Unlike) $ytmsclu_addjob "$url" "unlike" ;;
            Remove) $ytmsclu_addjob "$url" "remove" ;;
            Like) $ytmsclu_addjob "$url" "like" ;;
        esac
        ;;
    *)
        idp="${filename##*[}"
        id="${idp%]*}"
        if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
            url="https://www.youtube.com/watch?v=$id"
            echo -n "$url" | xsel -ib
        else
            notify-send -u critical -t 0 ytmsclu "Seomthing is wrong!\n'$path'"
            exit
        fi
        ;;
esac

