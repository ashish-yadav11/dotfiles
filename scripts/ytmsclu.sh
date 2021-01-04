#!/bin/bash
modifier=108
keyboard="AT Translated Set 2 keyboard"

[[ $1 != 1 && $1 != 0 ]] && { echo "Usage: $0 1|0"; exit ;}

exec 9>/tmp/ytm.lock
flock 9

press_key() {
    if [[ $(xinput query-state "$keyboard") == *"key[$modifier]=down"* ]] ; then
        xdotool keyup --delay 0 "$modifier" key "$1" keydown --delay 0 "$modifier"
        [[ $(xinput query-state "$keyboard") == *"key[$modifier]=up"* ]] &&
            xdotool keyup --delay 0 "$modifier"
    else
        xdotool key "$1"
    fi
}

hide_exit() {
        [[ -n $ytaf ]] || sigdwm "scrh i 2"
        exit
}

if [[ $(focusedwinclass -i) == crx_cinhimbnkkaeohfgghhklpknlkffjgod ]] ; then
    # YouTube Music window already focused
    ytaf=1
else
    if [[ $(xwininfo -children -root) == *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '* ]] ; then
        sigdwm "scrs i 2"
        sleep 0.1
    else
        exit
    fi
fi

# exit if the focused window doesn't have YouTube Music at the end of its title
[[ $(xdotool getactivewindow getwindowname) == *"YouTube Music" ]] || exit

geometry=$(xdotool getactivewindow getwindowgeometry)
position=${geometry##*Position: }
size=${position##*Geometry: }
# coordinates of right upper corner of the YouTube Music window
x0=${position%%,*}
y0=${position##*,}; y0=${y0%% (screen: *}
# size of the YouTube Music window
x=${size%%x*}
y=${size##*x}

# coordinates of a black pixel on the left side of the bottom status bar
Xb=$(( x0 + 9 ))
Yb=$(( y0 + y - 40 ))
# size of the pixel array to capture and analyze; 500 cut from left side and 300 from right
Xs=$(( x - 800 ))
# coordinates of the pixel which will be the leftmost point of the pixel array to be captured later
# on x-axis start from 504 right from the left border
X0=$(( x0 + 504 ))
# on y-axis start from 35 above from the bottom border
Y0=$(( y0 + y - 35 ))

if (( x < 944 || y < 65 )) ; then
    notify-send -t 3000 "YouTube Music L/U Script" \
        "The size of the YouTube Music window is less than can be tolerated by the script."
    exit
fi
if (( Xb < 0 || Xb > 1365 || Yb < 0 || Yb > 767 || X0 < 0 || (X0 + Xs) > 1365 || Y0 < 0 || Y0 > 767 )) ; then
    notify-send -t 4000 "YouTube Music L/U Script" \
        "The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
    exit
fi
if [[ $(import -window root -depth 8 -crop "1x1+${Xb}+${Yb}" txt:- | grep -om1 '#\w\+') != "#212121" ]] ; then
    notify-send -u critical -t 0 "YouTube Music L/U Script" "Something is wrong!"
    exit
fi

if [[ $1 == 1 ]] ; then

    mapfile -t ytmglst < <( import -window root -depth 8 -crop "${Xs}x1+${X0}+${Y0}" txt:- |
        awk -F'[, ]' '/#[7-9][0-9A-F][7-9][0-9A-F][7-9][0-9A-F]/ {print $1}' )

    for i in "${!ytmglst[@]}" ; do
        if (( ytmglst[i + 1] == ytmglst[i] + 1 && ytmglst[i + 2] == ytmglst[i] + 2 &&
              ytmglst[i + 3] == ytmglst[i] + 3 && ytmglst[i + 4] == ytmglst[i] + 6 &&
              ytmglst[i + 5] == ytmglst[i] + 7 )) ; then
            press_key plus
            hide_exit
        fi
    done
    hide_exit

else

    mapfile -t ytmglst < <( import -window root -depth 8 -crop "${Xs}x1+${X0}+${Y0}" txt:- |
        awk -F'[, ]' '/#[D-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]/ {print $1}' )

    for i in "${!ytmglst[@]}" ; do
        if (( ytmglst[i + 1]  == ytmglst[i] + 1 && ytmglst[i + 2]  == ytmglst[i] + 2 &&
              ytmglst[i + 3]  == ytmglst[i] + 3 && ytmglst[i + 4]  == ytmglst[i] + 6 &&
              ytmglst[i + 5]  == ytmglst[i] + 7 && ytmglst[i + 8]  == ytmglst[i] + 10 &&
              ytmglst[i + 11] == ytmglst[i] + 13 )) ; then
            press_key plus
            hide_exit
        fi
    done
    hide_exit

fi
