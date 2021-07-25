#!/bin/dash
output="$(pixelcolor)"
color="${output#*:}"; output="${output%:*}"
x="${output%,*}"
y="${output#*,}"
echo -n "$color" | xsel -ib
notify-send "x: $x  y: $y  color: $color"
