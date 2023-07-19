#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu.lock"
historyfile="/home/ashish/.config/BraveSoftware/Brave-Browser/Default/History"
ytb_isliked="/home/ashish/.local/bin/ytb-isLiked"
ytb_title="/home/ashish/.local/bin/ytb-title"
ytm_lastplayed="/home/ashish/.local/bin/ytm-lastPlayed"
ytmsclu_addjob="/home/ashish/.scripts/ytmsclu-addjob.sh"

nid=$(dunstify -p -t 500 ytmsclu "ytmsclu launched")

exec 9<>"$lockfile"
flock 9

menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}
                     entry {enabled: false;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

notify() {
    dunstify -C "$nid"
    dunstify "$@"
}
notifyerror() {
    notify -u critical -t 0 ytmsclu "$1"
}

unlockexit() {
    # xsel forks and takes the lock with it (see `man flock`)
    flock -u 9
    exit
}

if ! urltitle="$( \
    sqlite3 "file:$historyfile?mode=ro&nolock=1" \
        "SELECT url,title FROM urls ORDER BY last_visit_time DESC LIMIT 30" |
            grep -m1 "^https://music\.youtube\.com")" ; then
    notifyerror "Error: no valid YouTube Music urls found in recent history!"
    unlockexit
fi
url="${urltitle%%|*}"
if ! echo "$url" | grep -qm1 \
        "^https://music\.youtube\.com/watch?v=...........\($\|&\)" ; then
    nid="$(notify -p -t 1000 ytmsclu "Falling back to the 'lastplayed' script")"
    if ! urltitle="$($ytm_lastplayed)" ; then
        notifyerror "Error: something went wrong with the 'lastplayed' script!"
        unlockexit
    fi
    url="${urltitle%%|*}"
    echo -n "$url" | xsel -ib
    title="${urltitle#*|}"
else
    url="${url%%&*}"
    echo -n "$url" | xsel -ib
    title="${urltitle#*|}"
    title="${title%"YouTube Music"}"
    title="${title%" - "}"
    if [ -z "$title" ] ; then
        if ! title="$($ytb_title "$url")" ; then
            notifyerror "Error: something went wrong with the 'title' script!"
            unlockexit
        fi
    fi
fi
ytmtitle="$(xdotool search --classname crx_cinhimbnkkaeohfgghhklpknlkffjgod getwindowname)"
ytmtitle="${ytmtitle%"YouTube Music"}"
ytmtitle="${ytmtitle%" - "}"
ytmtitle="${ytmtitle#"YouTube Music - "}"
if [ -n "$ytmtitle" ] && [ "$ytmtitle" != "$title" ] ; then
    title="$title [${url##*"/watch?v="}] (YTM window doesn't match!)"
else
    title="$title [${url##*"/watch?v="}]"
fi

$ytb_isliked "$url"
case "$?" in
    0) menuarg="Unlike\nRemove\nLike" ;;
    1) menuarg="Like\nUnlike\nRemove" ;;
    *)
        notifyerror "Error: something went wrong with the 'isliked' script!"
        unlockexit
        ;;
esac
case "$(echo "$menuarg" | menu -p "$title")" in
    Like) $ytmsclu_addjob "$url" "like" ;;
    Unlike) $ytmsclu_addjob "$url" "unlike" ;;
    Remove) $ytmsclu_addjob "$url" "remove" ;;
esac
unlockexit
