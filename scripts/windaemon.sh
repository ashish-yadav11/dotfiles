#!/bin/dash
file="$(mktemp -p "$HOME" "windows-$(date +%m%d)XXX.txt")"

getdsknum() {
    if [ "$1" -le 9 ] ; then
        dsknum="$1"
    elif [ "$1" -eq 10 ] ; then
        dsknum=0
    else
        dsknum=A
    fi
}

while true ; do
    sleep 300
    : >"$file"
    xwininfo -tree -root | grep '^     0' |
        awk -F': \\(' '{print $1}' | grep -v -F '(has no name)' |
            while read -r winid wintitle ; do
                desktop="$(xprop -id "$winid" _NET_WM_DESKTOP)"
                [ "$desktop" = "_NET_WM_DESKTOP:  not found." ] && continue
                desktop="${desktop#"_NET_WM_DESKTOP(CARDINAL) = "}"
                if [ "$desktop" -eq 0 ] ; then
                    desktop="S-"
                elif [ "$desktop" -le 11 ] ; then
                    getdsknum "$desktop"
                    desktop="N$dsknum"
                else
                    desktop="$(( desktop - 11 ))"
                    if [ "$desktop" -le 11 ] ; then
                        getdsknum "$desktop"
                        desktop="H$dsknum"
                    else
                        desktop="$(( desktop - 11 ))"
                        if [ "$desktop" -le 11 ] ; then
                            getdsknum "$desktop"
                            desktop="D$dsknum"
                        else
                            desktop="S$(( desktop - 11 ))"
                        fi
                    fi
                fi
                echo "$desktop $wintitle" >>"$file"
            done
    sort -o "$file" "$file"
done
