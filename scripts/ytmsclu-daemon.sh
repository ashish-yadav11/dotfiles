#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytmsclu-daemon.lock"
fifofile="$XDG_RUNTIME_DIR/ytmsclu-daemon.fifo"
logfile="/home/ashish/.cache/ytmsclu-daemon.log"
notifyerror="notify-send -u critical -t 0 ytmsclu-daemon"

exec 9<>"$lockfile"
flock -n 9 || { echo 'Error: another instance already active!'; exit 2 ;}

[ -p "$fifofile" ] || { rm -f "$fifofile"; mkfifo "$fifofile" ;}
tail -f "$fifofile" |
    while read -r url action; do
        echo "$(date +%Y%m%d-%H%M%S) $url $action" >>"$logfile"
        if ! echo "$url" | grep -qm1 \
                "^https://\(music\|www\)\.youtube\.com/watch?v=...........$" ; then
            $notifyerror "action: $action\nurl: $url\nError: invalid url!"
            echo "Error: invalid url!\n\n" >>"$logfile"
            continue
        fi
        case "$action" in
            like) ytm-like "$url" >>"$logfile" 2>&1 ;;
            unlike) ytm-unlike "$url" >>"$logfile" 2>&1 ;;
            remove) ytm-unlike -r "$url" >>"$logfile" 2>&1 ;;
            delete) ytm-removeUnliked "$url" >>"$logfile" 2>&1 ;;
            *)
                $notifyerror "action: $action\nurl: $url\nError: invalid action!"
                echo "Error: invalid action!\n\n" >>"$logfile"
                continue
                ;;
        esac
        [ "$?" != 0 ] &&
            $notifyerror "action: $action\nurl: $url\nError: something went wrong!"
        echo "\n" >>"$logfile"
    done
