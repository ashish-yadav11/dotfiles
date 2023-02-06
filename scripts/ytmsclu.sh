#!/bin/dash
modifier=108
keyboard="AT Translated Set 2 keyboard"
lockfile="$XDG_RUNTIME_DIR/ytm.hide"

ntwarnsize="The size of the YouTube Music window is less than that required by the script."
ntwarnpos="The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
ntwarnuncertain="Something is wrong!"
ntalreadyliked="Song already liked!"

[ "$1" != 1 ] && [ "$1" != 0 ] && { echo "Usage: $0 1|0"; exit ;}

exec 9<>"$lockfile"
flock 9

hide() {
    if [ -s "$lockfile" ] ; then
        if flock -u 9 && flock -n 9 ; then
            : >"$lockfile"
            sigdwm "scrh i 2"
        fi
    elif [ -z "$ytaf" ] ; then
        if flock -u 9 && flock -n 9 ; then
            sigdwm "scrh i 2"
        else
            echo 1 >"$lockfile"
        fi
    fi
    # just to be safe (forked processes inherit file descriptor and thus lock)
    flock -u 9
}

press_keys() {
    case "$(xinput query-state "$keyboard")" in
        *"key[$modifier]=down"*)
            xdotool keyup --delay 200 "$modifier" key "$@" keydown --delay 0 "$modifier"
            case "$(xinput query-state "$keyboard")" in
                *"key[$modifier]=up"*) xdotool keyup --delay 0 "$modifier" ;;
            esac
            ;;
        *)
            xdotool key "$@"
            ;;
    esac
}

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    # YouTube Music window already focused
    ytaf=1
else
    case "$(xwininfo -children -root)" in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.2
            ;;
        *)
            exit
            ;;
    esac
fi

# exit if the focused window doesn't have YouTube Music at the end of its title
case "$(xdotool getactivewindow getwindowname)" in
    *"YouTube Music") ;;
    *) exit ;;
esac

geometry="$(xdotool getactivewindow getwindowgeometry)"
geometry="${geometry#*Position: }"
position="${geometry% (screen: *}"
size="${geometry#*Geometry: }"
# coordinates of left upper corner of the YouTube Music window
x="${position%,*}"
y="${position#*,}"
# size of the YouTube Music window
w="${size%x*}"
h="${size#*x}"
if [ "$w" -lt 944 ] || [ "$h" -lt 65 ] ; then
    notify-send -u critical -t 3000 ytmsclu "$ntwarnsize"
    exit
fi

# coordinates of a black pixel on the left side of the bottom status bar
xb="$(( x + 9 ))"
yb="$(( y + h - 40 ))"
if [ "$xb" -lt 0 ] || [ "$xb" -gt 1365 ] || [ "$yb" -lt 0 ] || [ "$yb" -gt 767 ] ; then
    notify-send -u critical -t 4000 ytmsclu "$ntwarnpos"
    exit
fi
if [ "$(pixelcolor -q "$xb" "$yb")" != "#212121" ] ; then
    notify-send -u critical -t 0 ytmsclu "$ntwarnuncertain"
    exit
fi

# size of the pixel array to capture and analyze; 500 cut from left side and 300 from right
s="$(( w - 800 ))"
# coordinates of the pixel which will be the leftmost point of the pixel array to be captured
# on x-axis start from 504 right from the left border
x0="$(( x + 504 ))"
# on y-axis start from 35 above from the bottom border
y0="$(( y + h - 35 ))"
if [ "$(( x0 < 0 || x0 > 1365 || (x0 + s) > 1365 || y < 0 || y > 767 ))" = 1 ] ; then
    notify-send -u critical -t 4000 ytmsclu "$ntwarnpos"
    exit
fi
if [ "$1" = 1 ] ; then
    if pixelcolor -q "$x0" "$y0" "$s" | awk '
            {
                if ($0 ~ /^#[2-3].[2-3].[2-3].$/) {
                    if (p == 1 && b == 7) {
                        e = 1
                        exit
                    }
                    b++
                    next
                } else if ($0 ~ /^#[7-9].[7-9].[7-9].$/) {
                    if (w == 0 && b > 7) {
                        b = 0
                        w = 1
                        next
                    }
                    if (w == 1 && b == 3) {
                        b = 0
                        p = 1
                        next
                    }
                }
            }
            {
                    b = 0
                    w = 0
                    p = 0
            }
            END {
                exit !e
            }' ; then
        press_keys plus
#       press_keys y y
        xdotool mousemove "$((x + w - 30))" "$((y + 15))" click 1 sleep 0.1 \
                mousemove "$((x + w - 30))" "$((y + 80))" click 1 \
                mousemove "$((x + w - 30))" "$((y + 80))" click 1 \
                mousemove 10000 10000
    else
        notify-send -t 1500 ytmsclu "$ntalreadyliked"
    fi

else
    pixelcolor -q "$x0" "$y0" "$s" | awk '
        {
            if ($0 ~ /^#[2-3].[2-3].[2-3].$/) {
                if (p == 3 && b == 7) {
                    e = 1
                    exit
                }
                if (b == 0) {
                    if (p == 1 && w == 3) {
                        w = 0
                        p = 2
                    } else if (p == 2 && w > 7) {
                        w = 0
                        p = 3
                    }
                }
                b++
                next
            } else if ($0 ~ /^#[c-f].[c-f].[c-f].$/) {
                if (w == 0 && p == 0 && b > 7) {
                    b = 0
                    p = 1
                    w++
                    next
                }
                if (p > 0) {
                    b = 0
                    w++
                    next
                }
            }
        }
        {
                b = 0
                w = 0
                p = 0
        }
        END {
            exit !e
        }
    ' && press_keys plus
fi
hide
