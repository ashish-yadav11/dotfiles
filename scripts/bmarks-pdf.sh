#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    {
        spc = $0
        sub(/[^ ].*/, "", spc)
        level = length(spc) / 4 + 1
        printf "BookmarkBegin\nBookmarkTitle: %s", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\nBookmarkLevel: %s\nBookmarkPageNumber: %s\n", level, $NF
    }
' "$1"
