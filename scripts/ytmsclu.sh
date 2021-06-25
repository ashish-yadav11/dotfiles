#!/bin/dash
modifier=108
keyboard="AT Translated Set 2 keyboard"
lockfile=$XDG_RUNTIME_DIR/ytm.hide

ntwarnsize="The size of the YouTube Music window is less than that required by the script."
ntwarnpos="The position of the YouTube Music window is problematic. Some essential window parts are offscreen."
ntwarnuncertain="Something is wrong!"
ntwarnyank="The URL couldn't be yanked."

[ "$1" != 1 ] && [ "$1" != 0 ] && { echo "Usage: $0 1|0"; exit ;}

exec 9<>"$lockfile"
flock 9

hide_exit() {
    if [ -s "$lockfile" ] && flock -u 9 && flock -n 9 ; then
        : >"$lockfile"
        sigdwm "scrh i 2"
    elif [ -z "$ytaf" ] ; then
        if flock -u 9 && flock -n 9 ; then
            sigdwm "scrh i 2"
        else
            echo 1 >"$lockfile"
        fi
    fi
    exit
}

press_keys() {
    case $(xinput query-state "$keyboard") in
        *"key[$modifier]=down"*)
            xdotool keyup --delay 200 "$modifier" key "$@" keydown --delay 0 "$modifier"
            case $(xinput query-state "$keyboard") in
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
    case $(xwininfo -children -root) in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.1
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
geometry=${geometry#*Position: }
position=${geometry% (screen: *}
size=${geometry#*Geometry: }
# coordinates of right upper corner of the YouTube Music window
x=${position%,*}
y=${position#*,}
# size of the YouTube Music window
w=${size%x*}
h=${size#*x}
if [ "$w" -lt 944 ] || [ "$h" -lt 65 ] ; then
    notify-send -u critical -t 3000 ytmsclu "$ntwarnsize"
    exit
fi

# coordinates of a black pixel on the left side of the bottom status bar
xb=$(( x + 9 ))
yb=$(( y + h - 40 ))
if [ "$xb" -lt 0 ] || [ "$xb" -gt 1365 ] || [ "$yb" -lt 0 ] || [ "$yb" -gt 767 ] ; then
    notify-send -u critical -t 4000 ytmsclu "$ntwarnpos"
    exit
fi
if [ "$(pixelcolor -q "$xb" "$yb")" != "#212121" ] ; then
    notify-send -u critical -t 0 ytmsclu "$ntwarnuncertain"
    exit
fi

# size of the pixel array to capture and analyze; 500 cut from left side and 300 from right
s=$(( w - 800 ))
# coordinates of the pixel which will be the leftmost point of the pixel array to be captured
# on x-axis start from 504 right from the left border
x0=$(( x + 504 ))
# on y-axis start from 35 above from the bottom border
y0=$(( y + h - 35 ))
if [ "$(( x0 < 0 || x0 > 1365 || (x0 + s) > 1365 || y < 0 || y > 767 ))" = 1 ] ; then
    notify-send -u critical -t 4000 ytmsclu "$ntwarnpos"
    exit
fi
if [ "$1" = 1 ] ; then
    if pixelcolor "$x0" "$y0" "$s" | awk -F[,:] '
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
            }' ; then
        press_keys y y plus
    else
        press_keys y y
    fi
    sleep 0.1
    url=$(xsel -ob)
    case $url in
        "https://music.youtube.com/watch?v="*)
            url=${url%&list=*}
            echo -n "$url" | xsel -ib
            ;;
        *)
            notify-send -u critical -t 2000 ytmsclu "$ntwarnyank"
            ;;
    esac
else
    pixelcolor "$x0" "$y0" "$s" | awk -F[,:] '
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
    ' && press_keys plus
fi
hide_exit
