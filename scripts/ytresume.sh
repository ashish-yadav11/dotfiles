#!/bin/dash
modifier_sym=Alt_R
modifier_code=108
keyboard="AT Translated Set 2 keyboard"

ntwarnpos="The position of the YouTube Music window is problematic. Some essential window parts are offscreen."

exec 9<>/tmp/ytm.hide
flock 9

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
        notify-send -t 4000 ytresume "$ntwarnpos"
        exit
    fi
    if [ "$(pixelcolor -q "$Xp" "$Yp")" = "#ffffff" ] ; then
        press_key space
        hide_exit
    fi
fi

Xw=$(( x0 + 32 ))
Yw=$(( y0 + 59 ))

if [ "$Xw" -lt 0 ] || [ "$Xw" -gt 1365 ] || [ "$Yw" -lt 0 ] || [ "$Yw" -gt 767 ] ; then
    notify-send -t 4000 ytresume "$ntwarnpos"
    exit
fi

i=0
while [ "$i" -lt 5 ] ; do
    case $(pixelcolor -q "$Xw" "$Yw") in
        "#333333")
            press_key Escape
            hide_exit
            ;;
        "#ffffff")
            exit
            ;;
        *)
            sleep 0.05
            i=$(( i + 1 ))
            ;;
    esac
done

press_key F5
sleep 0.2
hide_exit
