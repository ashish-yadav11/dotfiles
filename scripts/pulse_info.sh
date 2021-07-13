#!/bin/dash
pactl list sinks | awk '
    {
        if ($1 == "Mute:" && $2 == "yes") {
            i += 1
        } else if ($1 == "Volume:") {
            f=1
            if ($3 == $10) {
                vb = $5
            } else {
                vl = $5
                vr = $12
            }
        } else if ($1 == "Active" && $2 == "Port:" && tolower($3) ~ /headphone/) {
            i += 2
            exit
        }
        next
    }
    END {
        if (f) {
            if (vb)
                printf "%d%s", i, vb
            else
                printf "%dL%s R%s", i, vl, vr
        }
    }
'
