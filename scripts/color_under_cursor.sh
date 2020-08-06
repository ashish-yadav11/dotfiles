#!/bin/dash
# Get hex rgb color under mouse cursor, put it into clipboard and notify
location=$(xdotool getmouselocation)
x=${location#x:}; x=${x%% y:*}
y=${location#*y:}; y=${y%% screen:*}
color=$(import -window root -depth 8 -crop "1x1+${x}+${y}" txt:- |
    grep -om1 '#\w\+' | tr '[:upper:]' '[:lower:]')
echo -n "$color" | xclip -i -selection CLIPBOARD
notify-send "x: $x  y: $y  color: $color"
