#!/bin/bash

hide_exit() {
        [ -n "$ytaf" ] || xsetroot -name "z:scrh i 2"
        exit
}

[[ -z $1 ]] && { echo "Usage: $0 1|0"; exit ;}

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    # YouTube Music container already focused
    ytaf=1
else
    if xwininfo -tree -root | grep -q '("crx_cinhimbnkkaeohfgghhklpknlkffjgod" ' ; then
        xsetroot -name "z:scrs i 2"
        sleep 0.010
    else
        exit
    fi
fi

# exit if the focused container doesn't contain YouTube Music window
[[ $(xdotool getactivewindow getwindowname) =~ "YouTube Music"$ ]] || exit

geometry=$(xdotool getactivewindow getwindowgeometry)
position=${geometry##*Position: }
size=${position##*Geometry: }
# coordinates of right upper corner of the main YouTube Music window
x0=${position%%,*}
y0=${position##*,}; y0=${y0%% (screen: *}
# size of the main YouTube Music window
x=${size%%x*}
y=${size##*x}

# coordinates of the black pixel with coordinates (9,40) wrt left lower corner
Xb=$(( x0+9 ))
Yb=$(( y0+y-40 ))

if [[ ! $(import -window root -depth 8 -crop "1x1+${Xb}+${Yb}" txt:- | grep -om1 "#\w\+") == "#212121" ]] ; then
    notify-send -u critical -t 0 "YouTube Music L/U Script" "Something is wrong!"
    hide_exit
fi

# size of the pixel array to capture and analyze; 500 cut from left side and 300 from right
Xs=$(( x-800 ))
# coordinates of the pixel which will be the leftmost point of the pixel array to be captured later
# on x-axis start from 504 right from the left border
X0=$(( x0+504 ))
# on y-axis start from 35 above from the bottom border
Y0=$(( y0+y-35 ))

if [[ $x -lt 944 || $y -lt 65 ]] ; then
    notify-send -t 3000 "YouTube Music L/U Script" \
        "The size of the YouTube Music window is less than can be tolerated by the script."
    hide_exit
fi
if [[ $X0 -lt 0 || $(( X0+Xs )) -gt 1365 || $Y0 -lt 0 || $Y0 -gt 767 ]] ; then
    notify-send -t 4000 "YouTube Music L/U Script" \
        "The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
    hide_exit
fi

if [[ $1 == 1 ]] ; then
    
    mapfile -t ytmglst < <( import -window root -depth 8 -crop "${Xs}x1+${X0}+${Y0}" txt:- |
        awk -F'[, ]' '/#[7-9][0-9A-F][7-9][0-9A-F][7-9][0-9A-F]/ {print $1}' )

    for i in ${!ytmglst[*]} ; do
        if [[ ${ytmglst[$(( i+1 ))]} == "$(( ${ytmglst[$i]}+1 ))" &&
              ${ytmglst[$(( i+2 ))]} == "$(( ${ytmglst[$i]}+2 ))" &&
              ${ytmglst[$(( i+3 ))]} == "$(( ${ytmglst[$i]}+3 ))" &&
              ${ytmglst[$(( i+4 ))]} == "$(( ${ytmglst[$i]}+6 ))" &&
              ${ytmglst[$(( i+5 ))]} == "$(( ${ytmglst[$i]}+7 ))" ]] ; then

            xdotool keyup ISO_Level3_Shift key plus
            hide_exit
        fi
    done
    hide_exit

elif [[ $1 == 0 ]] ; then

    mapfile -t ytmglst < <( import -window root -depth 8 -crop "${Xs}x1+${X0}+${Y0}" txt:- |
        awk -F'[, ]' '/#[D-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]/ {print $1}' )

    for i in ${!ytmglst[*]} ; do
        if [[ ${ytmglst[$(( i+1 ))]} == "$(( ${ytmglst[$i]}+1 ))" &&
              ${ytmglst[$(( i+2 ))]} == "$(( ${ytmglst[$i]}+2 ))" &&
              ${ytmglst[$(( i+3 ))]} == "$(( ${ytmglst[$i]}+3 ))" &&
              ${ytmglst[$(( i+4 ))]} == "$(( ${ytmglst[$i]}+6 ))" &&
              ${ytmglst[$(( i+5 ))]} == "$(( ${ytmglst[$i]}+7 ))" &&
              ${ytmglst[$(( i+8 ))]} == "$(( ${ytmglst[$i]}+10 ))" &&
              ${ytmglst[$(( i+11 ))]} == "$(( ${ytmglst[$i]}+13 ))" ]] ; then

            xdotool keyup ISO_Level3_Shift key plus
            hide_exit
        fi
    done
    hide_exit
fi
