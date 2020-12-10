#!/bin/dash
xev | awk -F'[ )]+' '{
    if (c) {
        if (!--c) {
            printf "%-3s %s\n", $5, $8
        }
    } else if ($0 ~ /^KeyPress/) {
        c = 2
    }
}'
