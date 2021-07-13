#!/bin/dash
xev | awk -F'[ )]+' '
    c {
        if (!--c)
            printf "%-3s %s\n", $5, $8
        next
    }
    /^KeyPress/ {
        c = 2
    }
'
