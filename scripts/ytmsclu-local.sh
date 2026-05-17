#!/bin/dash
musicdir=/media/storage/Music
ytmsclu_addjob="/home/ashish/.scripts/ytmsclu-addjob.sh"
notifyerror="notify-send -u critical -t 0 ytmsclu-local"

menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}
                     entry {enabled: false;}' \
         -kb-accept-entry 'Control+m,Return,[172],MouseExtra92,MouseExtra91,MouseExtra98' \
         -kb-cancel 'Escape,Control+g,Control+bracketleft,semicolon,[123],MouseExtra93,MouseExtra99' \
         -kb-row-down 'Down,Control+j,[122]' -no-click-to-exit \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

path="$1"
filename="${path##*/}"
case "$path" in
    /*) ;;
    *) path="$PWD/$path" ;;
esac

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
        title="${filename%" ($id)"*} [$id]"
        case "$path" in
            "$musicdir/archive/"*) menuarg="Like\nDelete\nUnlike*" ;;
                                *) menuarg="Unlike\nRemove\nLike*" ;;
        esac
        eval $(xdotool getmouselocation --shell)
        xte "mousemove 1350 50"
        case "$(echo "$menuarg" | menu -p "$title")" in
            Unlike*) $ytmsclu_addjob "$url" "unlike" "$title" ;;
            Remove*) $ytmsclu_addjob "$url" "remove" "$title" ;;
            Like*) $ytmsclu_addjob "$url" "like" "$title" ;;
            Delete*) $ytmsclu_addjob "$url" "delete" "$title" ;;
            *) notify-send -t 700 ytmsclu-local 'ytmsclu aborted!' ;;
        esac
        xte "mousemove $X $Y"
        ;;
    *)
        $notifyerror "Error: not in music directory"
        exit
        ;;
esac

