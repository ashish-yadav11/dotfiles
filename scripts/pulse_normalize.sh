#!/bin/dash
volume=$(
    pacmd list-sinks | awk '
        {
            if (f) {
                if ($1 == "index:") {
                    exit
                }
                if ($1 == "volume:") {
                    v = $3 <= $10 ? $5 : $12
                    sub(/%/, "", v)
                    v = int(v / 5) * 5
                }
            } else if ($1 == "*" && $2 == "index:") {
                f = 1
            }
        }
        END {
            if (f) {
                print v
            } else {
                exit 1
            }
        }
    '
) && pactl set-sink-volume @DEFAULT_SINK@ "$volume%"
