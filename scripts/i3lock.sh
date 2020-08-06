#!/bin/dash

B='#303030ff'   # blank
D='#f37d7dff'   # default
T='#a0a0a0ff'   # text 
Ti='#7cf6e6ff'  # time
Da='#f0ed6dff'  # date
H='#efefefdd'   # highlight
W='#ff4040ff'   # wrong
Ba='#909090ff'  # backspace

i3lock \
--image=/media/storage/Pictures/wall6.png \
\
--insidecolor=$B \
--insidevercolor=$B \
--insidewrongcolor=$W \
--linecolor='#00000000' \
--radius 115 \
--ring-width 15 \
--ringcolor=$D \
--ringvercolor=$D \
--ringwrongcolor=$W \
--keyhlcolor=$H \
--bshlcolor=$Ba \
--separatorcolor=$D \
\
--noinputtext="" \
--veriftext="Verifying.." \
--verifcolor=$T \
--verifsize=35 \
--wrongtext="" \
--wrongcolor=$T \
--wrongsize=35 \
\
--indicator \
--clock \
--timestr="%l:%M %P" \
--timecolor=$Ti \
--timesize=35 \
--timepos=683:375 \
--datestr="%a, %b %d" \
--datecolor=$Da \
--datesize=35 \
--datepos=683:415 \
\
--refresh-rate=0.5
