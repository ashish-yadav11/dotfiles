#!/bin/dash
file="$(mktemp -p "$HOME" "windows-$(date +%y%m%d%H%M%S)$DISPLAY-XXX.txt")"

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
    wmctrl -l | tac |
            while read -r w desktop m wintitle ; do
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
                echo "$desktop $wintitle"
            done >"$file"
}

case "$1" in
    -h)
        echo "savewintitles [-h|d]"
        ;;
    -d)
        while true ; do
            savewintitles
            sleep 300
        done
        ;;
    *)
        savewintitles
        ;;
esac
