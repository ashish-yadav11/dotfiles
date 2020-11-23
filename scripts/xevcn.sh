#!/bin/dash
xev | awk -F'[ )]+' 'c && !--c {printf "%-3s %s\n", $5, $8}; /^KeyPress/ {c=2}'
