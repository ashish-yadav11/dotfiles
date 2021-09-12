#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy"

rt="Root"
fw="Focused window"
sl="Selection"
selection="$(echo "$rt\n$fw\n$sl" | $menu -no-custom -p Maim)" || exit
case "$selection" in
    "$rt") options="-i root" ;;
    "$fw") options="-i $(xdotool getactivewindow)" ;;
    "$sl") options="-s -b 1 -p -1" ;;
        *) exit ;;
esac

cn="Without cursor"
cy="With cursor"
selection="$(echo "$cn\n$cy" | $menu -no-custom -p Maim)" || exit
case "$selection" in
    "$cn") cursor="-u" ;;
    "$cy") cursor="" ;;
        *) exit ;;
esac

cleanexit() {
    rm -f "$tmpfile"
    exit
}

tmpfile="$(mktemp /tmp/screenshot-XXXXXX)"
maim -q -f png -m 10 $cursor $options "$tmpfile" || cleanexit

savescreenshot() {
    cb="Clipboard"
    dl="Default location"
    location="$(echo "$dl\n$cb" | $menu -p "Where to save the image?")"
    [ -z "$location" ] && cleanexit
    case "$location" in
        "$dl") location="$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H%M%S).png" ;;
        "$cb") clipboard=1 ;;
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
