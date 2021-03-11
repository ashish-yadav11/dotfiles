#!/bin/dash
notify="dunstify -h string:x-canonical-private-synchronous:pomodoro"

if [ -n "$1" ] ; then
    case $1 in
        status)
            if read -r PID </tmp/pomodoro.pid && kill -0 "$PID" ; then
                $notify -t 1000 "pomodoro up"
            else
                $notify -t 1000 "pomodoro down"
            fi
            exit
            ;;
        stop)
            read -r PID </tmp/pomodoro.pid && kill "$PID" $(pgrep -P "$PID")
            $notify -t 1000 "pomodoro terminated"
            exit
            ;;
        *)
            [ "$1" -gt 0 ] 2>/dev/null || exit
            timeperiod=$(( $1 * 60 ))
            ;;
    esac
else
    timeperiod=1500
fi

read -r PID </tmp/pomodoro.pid && kill "$PID" $(pgrep -P "$PID")
trap '
    read -r NID </tmp/pomodoro.nid && dunstify -C "$NID"
    rm -f /tmp/pomodoro.nid /tmp/pomodoro.pid
    exit
' TERM
echo "$$" >/tmp/pomodoro.pid

block() {
    sleep "$timeperiod"
    $notify -bp -t 0 "$1" >/tmp/pomodoro.nid &
    wait "$!"
    : >/tmp/pomodoro.nid
}

$notify -t 1000 "🍅🍅🍅🍅"
block "☑️🍅🍅🍅"
block "☑️☑️🍅🍅"
block "☑️☑️☑️🍅"
block "☑️☑️☑️☑️"
rm -f /tmp/pomodoro.nid /tmp/pomodoro.pid
