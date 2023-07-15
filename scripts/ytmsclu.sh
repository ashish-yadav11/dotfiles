#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu.lock"
lk_lockfile="$XDG_RUNTIME_DIR/zsh_lk.lock"
historyfile="/home/ashish/.config/BraveSoftware/Brave-Browser/Default/History"
ytb_isliked="/home/ashish/.local/bin/ytb-isLiked"
ytb_title="/home/ashish/.local/bin/ytb-title"

notify-send -t 500 ytmsclu "ytmsclu launched!"

exec 9<>"$lockfile"
flock 9
exec 8<>"$lk_lockfile"

unlockexit() {
    # xsel forks and takes the lock with it (see `man flock`)
    flock -u 9
    exit
}

menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}
                     entry {enabled: false;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

if ! urltitle="$( \
    sqlite3 "file:$historyfile?mode=ro&nolock=1" \
        "SELECT url,title FROM urls ORDER BY last_visit_time DESC LIMIT 30" |
            grep -m1 "^https://\(music\|www\)\.youtube\.com")" ; then
    notify-send -u critical -t 2000 ytmsclu "No valid YouTube Music urls found in recent history!"
    unlockexit
fi
url="${urltitle%%|*}"
if ! echo "$url" | grep -qm1 \
        "^https://\(music\|www\)\.youtube\.com/watch?v=...........\($\|&\)" ; then
    notify-send -u critical -t 0 ytmsclu "Something is wrong!\n'$url'"
fi
title="${urltitle#*|}"

url="${url%%&*}"
echo -n "$url" | xsel -ib

title="${titlee%"YouTube Music"}"
title="${title%" - "}"
if [ -z "$title" ] ; then
    if ! title="$($ytb_title "$url")" ; then
        notify-send -u critical -t 0 ytmsclu "Something went wrong with the 'title' script!"
        unlockexit
    fi
fi
title="$title [${url##*"/watch?v="}]"

winid="$(xdotool search --classname scratch-st | head -n1)"
if [ -z "$winid" ] ; then
    notify-send -t 1500 ytmsclu "Scratch terminal not open!"
    unlockexit
fi
$ytb_isliked "$url"
case "$?" in
    0)
        echo "Unlike" | menu -p "$title" || unlockexit
        while ! flock -n 8 ; do
            echo "Unlike" | menu -p "(Scatch terminal busy!) $title" || unlockexit
        done
        flock -u 8
        xdotool key --window "$winid" u l k l Enter
        ;;
    1)
        echo "Like" | menu -p "$title" || unlockexit
        while ! flock -n 8 ; do
            echo "Like" | menu -p "(Scatch terminal busy!) $title" || unlockexit
        done
        flock -u 8
        xdotool key --window "$winid" d l k l Enter
        ;;
    *)
        notify-send -u critical -t 0 ytmsclu "Something went wrong with the 'isliked' script!"
        unlockexit
        ;;
esac
unlockexit
