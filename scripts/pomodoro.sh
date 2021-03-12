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
            if ! [ "$1" -gt 0 ] 2>/dev/null ; then
                $notify -u critical -t 2000 pomodoro "Interval should be an integer!"
                exit
            fi
            timeperiod=$(( $1 * 60 ))
            ;;
    esac
else
    timeperiod=1500
fi

exec 9<>/tmp/pomodoro.pid
flock -n 9 || read -r PID <&9 && kill "$PID" $(pgrep -P "$PID")
flock -w1 9 || $notify -u critical -t 0 pomodoro "Something went wrong!"
trap '
    read -r NID </tmp/pomodoro.nid && dunstify -C "$NID"
    flock -u 9 && flock -n 9 && rm -f /tmp/pomodoro.nid /tmp/pomodoro.pid
    exit
' TERM
echo "$$" >/tmp/pomodoro.pid

blocknotify() {
    sleep "$timeperiod"
    $notify -bp -t 0 "$1" >/tmp/pomodoro.nid &
    wait "$!"
    : >/tmp/pomodoro.nid
}

$notify -t 1000 "🍅🍅🍅🍅"
blocknotify "☑️🍅🍅🍅"
blocknotify "☑️☑️🍅🍅"
blocknotify "☑️☑️☑️🍅"
sleep "$timeperiod"
$notify -t 0 "☑️☑️☑️☑️"
rm -f /tmp/pomodoro.nid /tmp/pomodoro.pid
