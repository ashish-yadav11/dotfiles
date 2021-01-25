#!/bin/dash
getbtnsfile=/sys/class/backlight/radeon_bl0/actual_brightness
setbtnsfile=/sys/class/backlight/radeon_bl0/brightness

checkint() {
    if ! [ "$1" -eq "$1" ] 2>/dev/null ; then
        echo "Invalid argument!"
        exit
    fi
}

incbtns() {
    checkint "$inc"
    read -r btns <"$getbtnsfile"
    if [ "$btns" -eq 255 ] ; then
        echo "Brightness is at its maximum value of 255"
        exit
    fi
    btns=$(( btns + inc ))
    if [ "$btns" -gt 255 ] ; then
        echo 255 >"$setbtnsfile"
        [ -z "$quiet" ] && echo 255/255
    else
        echo "$btns" >"$setbtnsfile"
        [ -z "$quiet" ] && echo "$btns/255"
    fi
}

decbtns() {
    checkint "$dec"
    read -r btns <"$getbtnsfile"
    if [ "$btns" -eq 1 ] ; then
        echo "Brightness is at its minimum value of 1"
        exit
    fi
    btns=$(( btns - dec ))
    if [ "$btns" -lt 1 ] ; then
        echo 1 >"$setbtnsfile"
        [ -z "$quiet" ] && echo "1/255"
    else
        echo "$btns" >"$setbtnsfile"
        [ -z "$quiet" ] && echo "$btns/255"
    fi
}

if [ "$#" -eq 0 ] ; then
    read -r btns <"$getbtnsfile"
    echo "$btns/255"
else
    [ "$1" = -q ] && { quiet=1; shift ;}
    case "$1" in
        [+ip]*)
            inc=${1#?}
            incbtns
            ;;
        [-dm]*)
            dec=${1#?}
            decbtns
            ;;
        *[+ip])
            inc=${1%?}
            incbtns
            ;;
        *[-dm])
            dec=${1%?}
            decbtns
            ;;
        *)
            checkint "$1"
            if [ "$1" -ge 1 ] && [ "$1" -le 255 ] ; then
                echo "$1" >"$setbtnsfile"
            else
                echo "Invalid argument!"
            fi
            ;;
    esac
fi
