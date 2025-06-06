#!/bin/sh
sink="$(pactl get-default-sink)"
[ -n "$sink" ] || exit
volume="$( 
    pactl list sinks | awk -v sink="$sink" '
        BEGIN {
            step = 5
        }
        f {
            if ($1 == "Volume:") {
                v = $3 <= $10 ? $5 : $12
                sub(/%/, "", v)
                v = int(v / step + 1/2) * step
                f = 2
                exit
            }
            next
        }
        $1 == "Name:" && $2 == sink {
            f = 1
        }
        END {
            if (f == 2)
                print v
            else
                exit 1
        }
    '
)" && pactl set-sink-volume "$sink" "$volume%"
