#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/ytm.hide"
ytmisliked_script="/home/ashish/.local/bin/ytm-isLiked"
ytmtitle_script="/home/ashish/.local/bin/ytm-title"

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
if ! title="$($ytmtitle_script "$url")" ; then
    notify-send -u critical -t 0 ytmsclu "Something went wrong with title script!"
    exit
fi

winid="$(xdotool search --classname scratch-st | head -n1)"
if [ -z "$winid" ] ; then
    notify-send -t 1500 ytmsclu "Scratch terminal not open!"
    exit
fi
$ytmisliked_script "$url"
case "$?" in
    0)
        yad --image youtube-music --title ytmsclu \
            --button=Unlike:0 --button=Cancel:1 --text "$title" &&
                xdotool key --window "$winid" u l k Enter
        ;;
    1)
        yad --image youtube-music --title ytmsclu \
            --button=Like:0 --button=Cancel:1 --text "$title" &&
                xdotool key --window "$winid" d l k Enter
        ;;
    *)
        notify-send -u critical -t 0 ytmsclu "Something went wrong with isliked script!"
        exit
        ;;
esac
