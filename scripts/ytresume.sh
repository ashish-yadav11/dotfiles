#!/bin/dash
modifier=108
keyboard="AT Translated Set 2 keyboard"

ntwarnsize="The size of the YouTube Music window is less than can be tolerated by the script."
ntwarnpos="The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
ntwarnuncertain="Something is wrong!"

hide_exit() {
    if [ -s /tmp/ytm.hide ] && flock -u 9 && flock -n 9 ; then
        : >/tmp/ytm.hide
        sigdwm "scrh i 2"
    elif [ -z "$ytaf" ] ; then
        if flock -u 9 && flock -n 9 ; then
            sigdwm "scrh i 2"
        else
            echo 1 >/tmp/ytm.hide
        fi
    fi
    exit
}

press_key() {
    case $(xinput query-state "$keyboard") in
        *"key[$modifier]=down"*)
            xdotool keyup --delay 200 "$modifier" key "$1" keydown --delay 0 "$modifier"
            case $(xinput query-state "$keyboard") in
                *"key[$modifier]=up"*) xdotool keyup --delay 0 "$modifier" ;;
            esac
            ;;
        *)
            xdotool key "$1"
            ;;
    esac
}

checkpixelpos() {
    if [ "$1" -lt 0 ] || [ "$1" -gt 1365 ] || [ "$2" -lt 0 ] || [ "$2" -gt 767 ] ; then
        notify-send -u critical -t 4000 ytresume "$ntwarnpos"
        exit
    fi
}

exec 9<>/tmp/ytm.hide
flock 9

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    ytaf=1
else
    case $(xwininfo -children -root) in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.01
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
geometry=${geometry#*Position: }
position=${geometry% (screen: *}
size=${geometry#*Geometry: }
x=${position%,*}
y=${position#*,}
w=${size%x*}
h=${size#*x}
if [ "$w" -lt 944 ] || [ "$h" -lt 65 ] ; then
    notify-send -u critical -t 3000 ytresume "$ntwarnsize"
    exit
fi

xb=$(( x + 9 ))
yb=$(( y + h - 40 ))
checkpixelpos "$xb" "$yb"
i=0
while [ "$i" -lt 5 ] && [ "$(pixelcolor -q "$xb" "$yb")" != "#212121" ] ; do
    sleep 0.05
    i=$(( i + 1 ))
done
if [ "$i" = 5 ] ; then
    notify-send -u critical -t 0 ytresume "$ntwarnuncertain"
    exit
fi

xp=$(( x + 87 ))
yp=$(( y + h - 42 ))
checkpixelpos "$xp" "$yp"
if [ "$(pixelcolor -q "$xp" "$yp")" = "#ffffff" ] ; then
    press_key space
    hide_exit
fi

xw=$(( x + 32 ))
yw=$(( y + 59 ))
checkpixelpos "$xw" "$yw"

case $(pixelcolor -q "$xw" "$yw") in
    "#333333")
        press_key Escape
        hide_exit
        ;;
    "#ffffff")
        exit
        ;;
    *)
        press_key F5
        sleep 0.2
        hide_exit
        ;;
esac
