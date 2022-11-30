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
--pass-media-keys \
--pass-screen-keys \
--pass-power-keys \
--bshl-color="$backspace" \
--clock \
--color="$blank" \
--date-color="$date" \
--date-pos=683:415 \
--date-size=35 \
--date-str="%a, %b %d" \
--image=/media/storage/Pictures/wall6.png \
--indicator \
--inside-color="$blank" \
--insidever-color="$blank" \
--insidewrong-color="$wrong" \
--keyhl-color="$highlight" \
--line-color="$transparent" \
--no-modkey-text \
--noinput-text="" \
--radius=115 \
--ring-width=15 \
--ring-color="$default" \
--ringver-color="$default" \
--ringwrong-color="$wrong" \
--separator-color="$default" \
--time-color="$time" \
--time-pos=683:375 \
--time-size=35 \
--time-str="%R" \
--verif-color="$text" \
--verif-size=35 \
--verif-text="Verifying.." \
--wrong-color="$text" \
--wrong-size=35 \
--wrong-text=""
