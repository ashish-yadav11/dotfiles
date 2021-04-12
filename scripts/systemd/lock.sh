#!/bin/dash
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
--bshlcolor="$backspace" \
--clock \
--color="$blank" \
--datecolor="$date" \
--datepos=683:415 \
--datesize=35 \
--datestr="%a, %b %d" \
--image=/media/storage/Pictures/wall6.png \
--indicator \
--insidecolor="$blank" \
--insidevercolor="$blank" \
--insidewrongcolor="$wrong" \
--keyhlcolor="$highlight" \
--linecolor="$transparent" \
--no-modkeytext \
--noinputtext="" \
--radius=115 \
--ring-width=15 \
--ringcolor="$default" \
--ringvercolor="$default" \
--ringwrongcolor="$wrong" \
--separatorcolor="$default" \
--timecolor="$time" \
--timepos=683:375 \
--timesize=35 \
--timestr="%R" \
--verifcolor="$text" \
--verifsize=35 \
--veriftext="Verifying.." \
--wrongcolor="$text" \
--wrongsize=35 \
--wrongtext=""
