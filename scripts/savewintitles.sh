#!/bin/dash
file="$(mktemp -p "$HOME" "windows-$(date +%y%m%d%H%M%S)$DISPLAY-XXX.txt")"
scrdir="${HOME}/Pictures/screenshots/$(basename "$file" ".txt")"

getdsknum() {
    if [ "$1" -le 9 ] ; then
        dsknum="0$1"
    elif [ "$1" -eq 10 ] ; then
        dsknum=10
    else
        dsknum=00
    fi
}
savewintitles() {
    sigdwm "wlnc i 0"
    i=1
    rm -rf "$scrdir"
    mkdir -p "$scrdir"
    wmctrl -l 2>/dev/null | tac |
            while read -r winid desktop m wintitle ; do
                if [ "$desktop" -eq 0 ] ; then
                    desktop="S--"
                elif [ "$desktop" -le 11 ] ; then
                    getdsknum "$desktop"
                    desktop="${dsknum}N"
                else
                    desktop="$(( desktop - 11 ))"
                    if [ "$desktop" -le 11 ] ; then
                        getdsknum "$desktop"
                        desktop="${dsknum}H"
                    else
                        desktop="$(( desktop - 11 ))"
                        if [ "$desktop" -le 11 ] ; then
                            getdsknum "$desktop"
                            desktop="D$dsknum"
                        else
                            desktop="S0$(( desktop - 11 ))"
                        fi
                    fi
                fi
                echo "$desktop $winid $wintitle"
                scrname="$(printf "%s/%03d_%s_%s.jpg" "$scrdir" "$i" "$desktop" "$winid")"
                maim -q -f jpg -u -i "$winid" "$scrname"
                i="$(( i + 1))"
            done >"$file"
}

case "$1" in
    -h)
        echo "savewintitles [-h|d]"
        ;;
    -d)
        while true ; do
            savewintitles
            sleep 600
        done
        ;;
    *)
        savewintitles
        ;;
esac
