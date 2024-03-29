#!/bin/dash
dateformat="%H:%M"
interval=1500
notifyp="dunstify -h string:x-canonical-private-synchronous:pomodorop"
notifys="dunstify -h string:x-canonical-private-synchronous:pomodoros"

nidfile="$XDG_RUNTIME_DIR/pomodoro.nid"
pidfile="$XDG_RUNTIME_DIR/pomodoro.pid"

if [ -n "$1" ] ; then
    case "$1" in
        status)
            if read -r PID 2>/dev/null <"$pidfile" && kill -0 "$PID" ; then
                $notifys -t 1000 "pomodoro up"
            else
                $notifys -t 1000 "pomodoro down"
            fi
            exit
            ;;
        stop)
            read -r PID 2>/dev/null <"$pidfile" && kill "$PID" $(pgrep -P "$PID")
            $notifys -t 1000 "pomodoro terminated"
            exit
            ;;
        *)
            if ! [ "$1" -gt 0 ] 2>/dev/null ; then
                $notifys -u critical -t 2000 pomodoro "Interval should be an integer!"
                exit
            fi
            interval="$(( $1 * 60 ))"
            ;;
    esac
fi

exec 9<>"$pidfile"
flock -n 9 || { read -r PID 2>/dev/null <&9 && kill "$PID" $(pgrep -P "$PID") ;}
flock -w1 9 || $notifys -u critical -t 0 pomodoro "Something went wrong!"
trap '
    read -r NID 2>/dev/null <"$nidfile" && dunstify -C "$NID"
    flock -u 9 && flock -n 9 && rm -f "$nidfile" "$pidfile"
    exit
' HUP INT TERM
echo "$$" >"$pidfile"

blocknotify() {
    $notifyp -bp -t 0 "$(date +"$dateformat") $1" >"$nidfile" &
    wait "$!"
    : >"$nidfile"
}

simplenotify() {
    $notifyp -t "$1" "$(date +"$dateformat") $2"
}

simplenotify 1000 "🍅🍅🍅🍅"
sleep "$interval"
blocknotify "☑️🍅🍅🍅"
sleep "$interval"
blocknotify "☑️☑️🍅🍅"
sleep "$interval"
blocknotify "☑️☑️☑️🍅"
sleep "$interval"
simplenotify 0 "☑️☑️☑️☑️"
rm -f "$nidfile" "$pidfile"
