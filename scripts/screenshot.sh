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

tmpfile="$(mktemp /tmp/screenshot-XXXXXX)"
maim -q -f png -m 10 $cursor $options "$tmpfile" || { rm -f "$tmpfile"; exit ;}

cb="Clipboard"
dl="Default location"
location="$(echo "$dl\n$cb" | $menu -p "Where to save the image?")"
[ -z "$location" ] && { rm -f "$tmpfile"; exit ;}
case "$location" in
    "$dl") location="$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H%M%S).png" ;;
    "$cb") clipboard=1 ;;
    [!/]*) location="$HOME/$location" ;;
esac
if [ -n "$clipboard" ] ; then
    xclip -selection clipboard -t image/png -i "$tmpfile"
else
    dir="${location%/*}"
    if [ -d "$dir" ] ; then
        ext="${location##*.}"
        if [ -z "$ext" ] || [ "$ext" = png ] ; then
            rmnot=1
            mv "$tmpfile" "$location"
        else
            convert "$tmpfile" "$location"
        fi
    else
        case "$dir" in "$HOME"*) dir="~${dir#"$HOME"}" ;; esac
        notify-send -u critical Maim "$dir is not a directory"
    fi
fi
notify-send -t 1000 Maim "Screenshot captured"
[ -z "$rmnot" ] && rm -f "$tmpfile"
