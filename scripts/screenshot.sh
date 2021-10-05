#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy"

sl="Selection"
fw="Focused window"
rt="Root"
selection="$(echo "$sl\n$fw\n$rt" | $menu -no-custom -p Maim)" || exit
case "$selection" in
    "$sl") options="-s -b 1 -p -1" ;;
    "$fw") options="-i $(xdotool getactivewindow)" ;;
    "$rt") options="-i root" ;;
        *) exit ;;
esac

case "$1" in
    0) cursor="-u" ;;
    1) cursor="" ;;
    *)
        cn="Without cursor"
        cy="With cursor"
        selection="$(echo "$cn\n$cy" | $menu -no-custom -p Maim)" || exit
        case "$selection" in
            "$cn") cursor="-u" ;;
            "$cy") cursor="" ;;
                *) exit ;;
        esac
        ;;
esac

cleanexit() {
    rm -f "$tmpfile"
    exit
}

takescreenshot() {
    tmpfile="$(mktemp /tmp/screenshot-XXXXXX)"
    maim -q -f png -m 10 $cursor $options "$tmpfile" || cleanexit
}
takescreenshot

savescreenshot() {
    cb="Copy image to clipboard"
    dl="Save image in Default location"
    rt="Retake"
    location="$(echo "$cb\n$dl\n$rt" | $menu -p "Where to save the image?")"
    [ -z "$location" ] && cleanexit
    case "$location" in
        "$cb") clipboard=1 ;;
        "$dl") location="$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H%M%S).png" ;;
        "$rt") rm -f "$tmpfile"; takescreenshot; savescreenshot; return ;;
        [!/]*) location="$HOME/$location" ;;
    esac
    if [ -n "$clipboard" ] ; then
        xclip -selection clipboard -t image/png -i "$tmpfile"
    else
        dir="${location%/*}"
        if ! [ -d "$dir" ] ; then
            cr="Create the directory"
            cn="Choose new location"
            ab="Abort screenshot"
            case "$dir" in "$HOME"*) tdir="~${dir#"$HOME"}" ;; esac
            choice="$(echo "$cr\n$cn\n$ab" |
                $menu -no-custom -p "Directory $tdir doesn't exist!")" || cleanexit
            case "$choice" in
                "$cr") mkdir -p "$dir" ;;
                "$cn") savescreenshot; return ;;
                "$ab") cleanexit ;;
            esac
        fi
        ext="${location##*.}"
        if [ -z "$ext" ] || [ "$ext" = png ] ; then
            rmnot=1
            mv "$tmpfile" "$location"
        else
            convert "$tmpfile" "$location"
        fi
    fi
}
savescreenshot
notify-send -t 1000 Maim "Screenshot captured"
[ -z "$rmnot" ] && rm -f "$tmpfile"
