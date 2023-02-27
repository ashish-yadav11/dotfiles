#!/bin/dash
getbtnsfile=/sys/class/backlight/radeon_bl0/actual_brightness
setbtnsfile=/sys/class/backlight/radeon_bl0/brightness

processval() {
    val="$1"
    case "$1" in *%) val="${1%\%}" ;; esac
    if ! [ "$val" -eq "$val" ] 2>/dev/null ; then
        echo "Invalid argument!"
        exit
    fi
    case "$1" in *%) val="$(( (255 * val) / 100 ))" ;; esac
}

incbtns() {
    processval "$1"
    read -r btns <"$getbtnsfile"
    if [ "$btns" -eq 255 ] ; then
        echo "Brightness is at its maximum value of 255"
        exit
    fi
    btns="$(( btns + val ))"
    if [ "$btns" -gt 255 ] ; then
        echo 255 >"$setbtnsfile"
        [ -z "$quiet" ] && echo 255/255
    else
        echo "$btns" >"$setbtnsfile"
        [ -z "$quiet" ] && echo "$btns/255"
    fi
}

decbtns() {
    processval "$1"
    read -r btns <"$getbtnsfile"
    if [ "$btns" -eq 1 ] ; then
        echo "Brightness is at its minimum value of 1"
        exit
    fi
    btns="$(( btns - val ))"
    if [ "$btns" -lt 1 ] ; then
        echo 1 >"$setbtnsfile"
        [ -z "$quiet" ] && echo "1/255"
    else
        echo "$btns" >"$setbtnsfile"
        [ -z "$quiet" ] && echo "$btns/255"
    fi
}

setbtns() {
    processval "$1"
    if [ "$val" -ge 1 ] && [ "$val" -le 255 ] ; then
        echo "$val" >"$setbtnsfile"
    else
        echo "Invalid argument!"
    fi
}

if [ "$#" -eq 0 ] ; then
    read -r btns <"$getbtnsfile"
    echo "$btns/255"
else
    [ "$1" = -q ] && { quiet=1; shift ;}
    case "$1" in
        [+ip]*)
            incbtns "${1#?}" ;;
        [-dm]*)
            decbtns "${1#?}" ;;
        *[+ip])
            incbtns "${1%?}" ;;
        *[-dm])
            decbtns "${1%?}" ;;
        *)
            setbtns "$1" ;;
    esac
fi
