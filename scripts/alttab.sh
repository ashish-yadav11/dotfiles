#!/bin/dash
ismod4down=/home/ashish/.scripts/alttab_helper

$ismod4down || { sigdwm "fclg i 0"; exit ;}

rofi -show window -steal-focus -no-lazy-grab \
    -kb-accept-entry '!Super+Super_R,Super+Return,Return' \
    -kb-cancel 'Super+Escape,Escape,Control+g,Control+bracketleft' \
    -kb-element-next 'Super+Tab,Super+Down,Super+Control+j,Tab' \
    -kb-element-prev 'Super+ISO_Left_Tab,Super+Up,Super+Control+k,ISO_Left_Tab' \
    -kb-remove-char-back 'Super+BackSpace,Super+Control+h,BackSpace,Shift+BackSpace,Control+h' \
    -kb-remove-char-back 'Super+BackSpace,Super+Control+h,BackSpace,Shift+BackSpace,Control+h' \
    -kb-remove-to-sol 'Super+Control+u,Control+u' \
    -selected-row 1 -no-plugins &
pid=$!

t=0.01
n=20
i=1
while [ "$i" -le "$n" ] ; do
    sleep "$t"
    $ismod4down || { kill "$pid" 2>/dev/null && sigdwm "fclg i 0"; exit ;}
    kill -0 "$pid" 2>/dev/null || exit
    i="$(( i + 1 ))"
done

# rofi options to show preview (it's slow though):
#   -show window -window-thumbnail -show-icons -scroll-method 0 \
#   -theme-str 'element { children: [ element-icon, element-text ]; orientation: vertical; }' \
#   -theme-str 'element-icon { size: 30ch; }' \
#   -theme-str 'listview { flow: horizontal; columns: 2; lines: 2; }' \
#   -theme-str 'window { width: 90%; }' \
