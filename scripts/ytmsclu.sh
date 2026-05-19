#!/bin/dash
ytmsclu_local="/home/ashish/.scripts/ytmsclu-local.sh"

case "$(playerctl status)" in
    *"org.mpris.MediaPlayer2.mpv"*": active"*)
        echo "run $ytmsclu_local \${path}" | socat - /tmp/music-mpv.socket
        exit ;;
esac

lockfile="$XDG_RUNTIME_DIR/ytmsclu.lock"
historyfile="/home/ashish/.config/BraveSoftware/Brave-Browser/Default/History"
logfile="/home/ashish/.cache/ytmsclu-daemon.log"
ytb_islikedlocal="/home/ashish/.local/bin/ytb-isLikedLocal"
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
         -kb-accept-entry 'Control+m,Return,[172],MouseExtra92,MouseExtra91,MouseExtra98' \
         -kb-cancel 'Escape,Control+g,Control+bracketleft,semicolon,[123],MouseExtra93,MouseExtra99' \
         -kb-row-down 'Down,Control+j,[122]' -no-click-to-exit \
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

geturltitle() {
    if [ "$1" = "-l" ] || ! urltitle="$( \
        sqlite3 "file:$historyfile?mode=ro&nolock=1" \
            "SELECT url,title FROM urls ORDER BY last_visit_time DESC LIMIT 30" |
                grep -m1 "^https://music\.youtube\.com/watch?v=...........[|&]"
        )" ; then

        if ! urltitle="$($ytm_lastplayed)" ; then
            notifyerror "Error: something went wrong with the 'lastplayed' script!"
            unlockexit
        fi
        url="${urltitle%%|*}"
        echo -n "$url" | xsel -ib
        title="${urltitle#*|}"
    else
        url="${urltitle%%|*}"
        url="${url%%&*}"
        echo -n "$url" | xsel -ib
        title="${urltitle#*|}"
        title="${title%"YouTube Music"}"
        title="${title%" | "}"
        if [ -z "$title" ] ; then
            if ! title="$($ytb_title "$url")" ; then
                notifyerror "Error: something went wrong with the 'title' script!"
                unlockexit
            fi
        fi
    fi
    titled="$title [${url##*"/watch?v="}]"
    titlem="$titled"
}

case "$(playerctl status)" in
    *"org.mpris.MediaPlayer2.brave"*": active"*)
        geturltitle "$1"
        ytmtitle="$(xdotool search --classname crx_cinhimbnkkaeohfgghhklpknlkffjgod getwindowname)"
        ytmtitle="${ytmtitle%"YouTube Music"}"
        ytmtitle="${ytmtitle%" | "}"
        ytmtitle="${ytmtitle#"YouTube Music - "}"
        if [ -n "$ytmtitle" ] && [ "$ytmtitle" != "$title" ] ; then
            geturltitle -l
            if [ "$ytmtitle" != "$title" ] ; then
                titlem="$titlem (YtM window title doesn't match!)"
            fi
        fi
        ;;
    *)
        geturltitle -l
        ;;
esac
if [ "$(awk 'p && NF {l = $2}; {p = (NF==0)}; END {print l}' "$logfile")" = "$url" ] ; then
    titlem="$titlem*"
fi

$ytb_islikedlocal "$url" >/dev/null
case "$?" in
    0) menuarg="Unlike\nRemove\nLike*" ;;
    1) menuarg="Like\nUnlike*\nRemove" ;;
    2) menuarg="Like\nUnlike\nRemove" ;;
    *)
        notifyerror "Error: something went wrong with the 'islikedlocal' script!"
        unlockexit
        ;;
esac
eval $(xdotool getmouselocation --shell)
xte "mousemove 1350 50"
case "$(echo "$menuarg" | menu -p "$titlem")" in
    Like*) $ytmsclu_addjob "$url" "like" "$titled";;
    Unlike*) $ytmsclu_addjob "$url" "unlike" "$titled" ;;
    Remove*) $ytmsclu_addjob "$url" "remove" "$titled" ;;
    *) notify -t 700 ytmsclu 'ytmsclu aborted!' ;;
esac
xte "mousemove $X $Y"
unlockexit
