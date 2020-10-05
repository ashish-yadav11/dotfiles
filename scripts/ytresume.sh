#!/bin/dash
xdotool keyup 108

hide_exit() {
        [ -n "$ytaf" ] || xsetroot -name "z:scrh i 2"
        exit
}

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    ytaf=1
else
    if xwininfo -tree -root | grep -q '("crx_cinhimbnkkaeohfgghhklpknlkffjgod" ' ; then
        xsetroot -name "z:scrs i 2"
        sleep 0.050
    else
        exec chromium --profile-directory="Profile 1" --app-id=cinhimbnkkaeohfgghhklpknlkffjgod
    fi
fi

case "$(xdotool getactivewindow getwindowname)" in
    *"YouTube Music")
        ;;
    *)
        xdotool key F5
        sleep 0.200
        hide_exit
        ;;
esac

geometry=$(xdotool getactivewindow getwindowgeometry)
position=${geometry##*Position: }
size=${position##*Geometry: }
x0=${position%%,*}
y0=${position##*,}; y0=${y0%% (screen: *}
x=${size%%x*}
y=${size##*x}

if [ "$x" -ge 944 ] && [ "$y" -ge 70 ] ; then
    Xp=$(( x0 + 87 ))
    Yp=$(( y0 + y - 42 ))

    if [ "$Xp" -lt 0 ] || [ "$Xp" -gt 1365 ] || [ "$Yp" -lt 0 ] || [ "$Yp" -gt 767 ] ; then
        notify-send -t 4000 "YouTube Music Resume Script" \
            "The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
        hide_exit
    fi

    if [ "$(import -window root -depth 8 -crop "1x1+${Xp}+${Yp}" txt:- | grep -om1 "#\w\+")" = "#FFFFFF" ] ; then
        xdotool key space
        hide_exit
    fi
fi

Xw=$(( x0 + 32 ))
Yw=$(( y0 + 59 ))

if [ "$Xw" -lt 0 ] || [ "$Xw" -gt 1365 ] || [ "$Yw" -lt 0 ] || [ "$Yw" -gt 767 ] ; then
    notify-send -t 4000 "YouTube Music Resume Script" \
        "The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
    hide_exit
fi

case "$(import -window root -depth 8 -crop "1x1+${Xw}+${Yw}" txt:- | grep -om1 "#\w\+")" in
    "#333333")
        xdotool key Escape
        hide_exit
        ;;
    "#FFFFFF")
        exit
        ;;
    *)
        xdotool key F5
        sleep 0.200
        hide_exit
        ;;
esac
