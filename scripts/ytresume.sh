#!/bin/dash
modifier=108
keyboard="AT Translated Set 2 keyboard"

exec 9>/tmp/ytm.lock
flock 9

press_key() {
    case $(xinput query-state "$keyboard") in
        *"key[$modifier]=down"*)
            xdotool keydown --delay 0 "$modifier" key "$1" keyup --delay 0 "$modifier"
            case $(xinput query-state "$keyboard") in
                *"key[$modifier]=up"*) xdotool keyup --delay 0 "$modifier" ;;
            esac
            ;;
        *)
            xdotool key --delay 0 "$1"
            ;;
    esac
}

hide_exit() {
    [ -n "$ytaf" ] || sigdwm "scrh i 2"
    exit
}

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    ytaf=1
else
    case $(xwininfo -children -root) in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.1
            ;;
        *)
            exec brave --app-id=cinhimbnkkaeohfgghhklpknlkffjgod
            ;;
    esac
fi

case $(xdotool getactivewindow getwindowname) in
    *"YouTube Music")
        ;;
    *)
        press_key F5
        sleep 0.2
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
        exit
    fi
    if [ "$(import -window root -depth 8 -crop "1x1+${Xp}+${Yp}" txt:- | grep -om1 '#\w\+')" = "#FFFFFF" ] ; then
        press_key space
        hide_exit
    fi
fi

Xw=$(( x0 + 32 ))
Yw=$(( y0 + 59 ))

if [ "$Xw" -lt 0 ] || [ "$Xw" -gt 1365 ] || [ "$Yw" -lt 0 ] || [ "$Yw" -gt 767 ] ; then
    notify-send -t 4000 "YouTube Music Resume Script" \
        "The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
    exit
fi

case $(import -window root -depth 8 -crop "1x1+${Xw}+${Yw}" txt:- | grep -om1 '#\w\+') in
    "#333333")
        press_key Escape
        hide_exit
        ;;
    "#FFFFFF")
        exit
        ;;
    *)
        press_key F5
        sleep 0.2
        hide_exit
        ;;
esac
