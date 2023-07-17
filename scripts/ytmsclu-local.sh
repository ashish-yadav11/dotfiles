#!/bin/dash
musicdir=/media/storage/Music
menu="dmenu -i -matching fuzzy -no-custom"
ytmsclu_addjob="/home/ashish/.scripts/ytmsclu-addjob.sh"
notifyerror="notify-send -u critical -t 0 ytmsclu-local"

path="$1"
filename="${path##*/}"

case "$path" in
    "$musicdir/"*)
        idp="${filename##*(}"
        id="${idp%)*}"
        if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
            url="https://music.youtube.com/watch?v=$id"
            echo -n "$url" | xsel -ib
        else
            $notifyerror "Error: file name not in expected format!\n'$filename'"
            exit
        fi
        title="${filename%" ($id)*"} [$id]"
        case "$path" in
            "$musicdir/archive/"*) menuarg="Like\nDelete\nUnlike" ;;
                                *) menuarg="Unlike\nRemove\nLike" ;;
        esac
        case "$(echo "$menuarg" | $menu -p "$title")" in
            Unlike) $ytmsclu_addjob "$url" "unlike" ;;
            Remove) $ytmsclu_addjob "$url" "remove" ;;
            Like) $ytmsclu_addjob "$url" "like" ;;
            Delete) $ytmsclu_addjob "$url" "delete" ;;
        esac
        ;;
    *)
        $notifyerror "Error: not in music directory"
        exit
        ;;
esac

