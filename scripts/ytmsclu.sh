#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytm.hide"
ytb_isliked="/home/ashish/.local/bin/ytb-isLiked"
ytb_title="/home/ashish/.local/bin/ytb-title"

exec 9<>"$lockfile"
flock 9

menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}
                     entry {enabled: false;}' \
         -dmenu -i -matching fuzzy -no-custom "$@"
}

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

if [ "$(focusedwinclass -i)" = crx_cinhimbnkkaeohfgghhklpknlkffjgod ] ; then
    # YouTube Music window already focused
    ytaf=1
else
    case "$(xwininfo -children -root)" in
        *': ("crx_cinhimbnkkaeohfgghhklpknlkffjgod" '*)
            sigdwm "scrs i 2"
            sleep 0.1
            ;;
        *)
            notify-send -t 1000 ytmsclu "YouTube Music not open!"
            exit
            ;;
    esac
fi

# exit if the focused window doesn't have YouTube Music at the end of its title
wintitle="$(xdotool getactivewindow getwindowname)"
case "$wintitle" in
    *"YouTube Music")
        ;;
    *)
        notify-send -t 1000 ytmsclu "Something wrong with window title!"
        exit
        ;;
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
#h="${size#*x}"

#eval $(xdotool getmouselocation --shell)
xdotool mousemove "$((x + w - 30))" "$((y + 15))" click 1 sleep 0.1 \
        mousemove "$((x + w - 30))" "$((y + 80))" click 1 \
        mousemove "$((x + w - 30))" "$((y + 80))" click 1 \
        mousemove 10000 10000
#       mousemove "$X" "$Y"
sleep 0.01

url="$(xsel -ob)"
if ! echo "$url" | grep -qm1 \
        "^https://\(music\|www\)\.youtube\.com/watch?v=...........\($\|&\)" ; then
    notify-send -u critical -t 0 ytmsclu "Something is wrong!\n'$url'"
    hide
    exit
fi
hide

url="${url%%&*}"
echo -n "$url" | xsel -ib

title="${wintitle%"YouTube Music"}"
title="${title%" - "}"
title="${title#"YouTube Music - "}"
if [ -z "$title" ] ; then
    if ! title="$($ytb_title "$url")" ; then
        notify-send -u critical -t 0 ytmsclu "Something went wrong with title script!"
        exit
    fi
fi

winid="$(xdotool search --classname scratch-st | head -n1)"
if [ -z "$winid" ] ; then
    notify-send -t 1500 ytmsclu "Scratch terminal not open!"
    exit
fi
$ytb_isliked "$url"
case "$?" in
    0)
        echo "Unlike" | menu -p "$title" &&
                xdotool key --window "$winid" u l k Enter
        ;;
    1)
        echo "Like" | menu -p "$title" &&
                xdotool key --window "$winid" d l k Enter
        ;;
    *)
        notify-send -u critical -t 0 ytmsclu "Something went wrong with isliked script!"
        exit
        ;;
esac
