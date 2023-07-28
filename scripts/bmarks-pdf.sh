#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    /^            /     { template(4); next }
    /^        /         { template(3); next }
    /^    /             { template(2); next }
                        { template(1); next }

    function template(level) {
        printf "BookmarkBegin\nBookmarkTitle: %s", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\nBookmarkLevel: %s\nBookmarkPageNumber: %s\n", level, $NF
    }
' "$1"
