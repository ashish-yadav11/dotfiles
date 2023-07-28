#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    /^BookmarkTitle: / {
        title = $0
        sub(/^BookmarkTitle: /, "", title)
        next
    }
    /^BookmarkLevel: / {
        printf "%*s%s ", 4*($2 - 1), "", title
        next
    }
    /^BookmarkPageNumber: / {
        printf "%s\n", $2
        next
    }
' "$1"
