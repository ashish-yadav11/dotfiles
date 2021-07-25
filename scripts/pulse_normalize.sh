#!/bin/dash
volume="$(
    pactl list sinks | awk '
        $1 == "Volume:" {
            f=1
            v = $3 <= $10 ? $5 : $12
            sub(/%/, "", v)
            v = int(v / 5) * 5
            exit
        }
        END {
            if (f)
                print v
            else
                exit 1
        }
    '
)" && pactl set-sink-volume @DEFAULT_SINK@ "$volume%"
