#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu-daemon.lock"
fifofile="$XDG_RUNTIME_DIR/ytmsclu-daemon.fifo"
logfile="/home/ashish/.cache/ytmsclu-daemon.log"
musicsync="/home/ashish/.scripts/musicsync.sh"
notifyerror="notify-send -u critical -t 0 ytmsclu-daemon"
notifydone="notify-send -t 2000 ytmsclu-daemon"

exec 9<>"$lockfile"
flock -n 9 || { echo 'Error: another instance already active!'; exit 2 ;}

failwarn() {
    echo -n "$url" | xsel -ib
    $notifyerror "action: $action\ntitle: $title\nError: something went wrong!"
    failed=1
}
syncfailwarn() {
    if [ "$1" = 0 ] ; then
        $musicsync >>"$logfile" 2>&1
    else
        failwarn
    fi
}

[ -p "$fifofile" ] || { rm -f "$fifofile"; mkfifo "$fifofile" ;}
tail -f "$fifofile" |
    while read -r url action title; do
        failed=0
        [ "$action" != history ] &&
            echo "$(date +%Y%m%d-%H%M%S) $url $action" >>"$logfile"
        if ! echo "$url" | grep -qm1 \
                "^https://\(music\|www\)\.youtube\.com/watch?v=...........$" ; then
            $notifyerror "action: $action\nurl: $url\nError: invalid url!"
            echo "Error: invalid url!\n\n" >>"$logfile"
            continue
        fi
        case "$action" in
            like) ytm-like "$url" >>"$logfile" 2>&1; syncfailwarn "$?" ;;
            unlike) ytm-unlike "$url" >>"$logfile" 2>&1 || failwarn ;;
            remove) ytm-removeLiked "$url" >>"$logfile" 2>&1 || failwarn ;;
            delete) ytm-removeUnliked "$url" >>"$logfile" 2>&1 || failwarn ;;
            history) ytm-addHistory "$url" >/dev/null 2>&1; continue ;;
            *)
                $notifyerror "action: $action\nurl: $url\nError: invalid action!"
                echo "Error: invalid action!\n\n" >>"$logfile"
                continue
                ;;
        esac
        [ "$failed" = 0 ] && $notifydone "action: $action\ntitle: $title\nTask done!"
        echo "\n" >>"$logfile"
    done
