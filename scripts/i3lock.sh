#!/bin/dash
pidof -s /usr/bin/i3lock >/dev/null 2>&1 && exit 0

backspace="#909090ff"
blank="#303030ff"
date="#f0ed6dff"
default="#f37d7dff"
highlight="#efefefdd"
text="#a0a0a0ff"
time="#7cf6e6ff"
transparent="#00000000"
wrong="#ff4040ff"

i3lock \
--image=/media/storage/Pictures/wall6.png \
\
--insidecolor="$blank" \
--insidevercolor="$blank" \
--insidewrongcolor="$wrong" \
--linecolor="$transparent" \
--radius 115 \
--ring-width 15 \
--ringcolor="$default" \
--ringvercolor="$default" \
--ringwrongcolor="$wrong" \
--keyhlcolor="$highlight" \
--bshlcolor="$backspace" \
--separatorcolor="$default" \
\
--noinputtext="" \
--veriftext="Verifying.." \
--verifcolor="$text" \
--verifsize=35 \
--wrongtext="" \
--wrongcolor="$text" \
--wrongsize=35 \
\
--indicator \
--clock \
--timestr="%l:%M %P" \
--timecolor="$time" \
--timesize=35 \
--timepos=683:375 \
--datestr="%a, %b %d" \
--datecolor="$date" \
--datesize=35 \
--datepos=683:415 \
\
--refresh-rate=0.5
