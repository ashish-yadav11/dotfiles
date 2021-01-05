#!/bin/dash
[ "$1" != 1 ] && [ "$1" != 0 ] && { echo "Usage: $0 1|0"; exit ;}

modifier=108
keyboard="AT Translated Set 2 keyboard"

ntwarnsize="The size of the YouTube Music window is less than can be tolerated by the script."
ntwarnpos="The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
ntwarnuncertain="Something is wrong!"

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
    # YouTube Music window already focused
    ytaf=1
else
    case $(xwininfo -children -root) in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.01
            ;;
        *)
            exit
            ;;
    esac
fi

# exit if the focused window doesn't have YouTube Music at the end of its title
case $(xdotool getactivewindow getwindowname) in
    *"YouTube Music") ;;
    *) exit ;;
esac

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

if [ "$x" -lt 944 ] || [ "$y" -lt 65 ] ; then
    notify-send -t 3000 ytmsclu "$ntwarnsize"
    exit
fi
if [ "$(( Xb < 0 || Xb > 1365 || Yb < 0 || Yb > 767 || X0 < 0 || (X0 + Xs) > 1365 || Y0 < 0 || Y0 > 767 ))" = 1 ] ; then
    notify-send -t 4000 ytmsclu "$ntwarnpos"
    exit
fi

i=0
while [ "$i" -lt 5 ] && [ "$(pixelcolor -q "$Xb" "$Yb")" != "#212121" ] ; do
    sleep 0.05
    i=$(( i + 1 ))
done
if [ "$i" = 5 ] ; then
    notify-send -u critical -t 0 ytmsclu "$ntwarnuncertain"
    exit
fi

if [ "$1" = 1 ] ; then
    pixelcolor "$X0" "$Y0" "$Xs" | awk -F[,:] '
        $3 ~ /#[7-9].[7-9].[7-9].$/ {
            x[++i % 6] = $1
            if (s != 5) {
                if (x[(i - 1) % 6] == $1 - 1 &&
                    x[(i - 5) % 6] == $1 - 7) {
                    e = 1
                    exit
                }
            } else {
                s++
            }
        }
        END {
            exit !e
        }
    ' && press_key plus
else
    pixelcolor "$X0" "$Y0" "$Xs" | awk -F[,:] '
        $3 ~ /#[d-f].[d-f].[d-f].$/ {
            x[++i % 17] = $1
            if (s != 16) {
                if (x[(i - 12) % 17] == $1 - 12 &&
                    x[(i - 16) % 17] == $1 - 18) {
                    e = 1
                    exit
                }
            } else {
                s++
            }
        }
        END {
            exit !e
        }
    ' && press_key plus
fi
hide_exit
