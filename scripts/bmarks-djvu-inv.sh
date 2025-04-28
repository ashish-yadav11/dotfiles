#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    /^ *\("/ {
        title = $0
        sub(/^ *\("/, "", title)
        sub(/" *$/, "", title)
        gsub(/\\"/, "\"", title)
        level += 1
        next
    }
    /^ *"#/ {
        pgnum = $0
        sub(/^ *"#/, "", pgnum)
        sub(/"[ )]*$/, "", pgnum)
        printf "%*s%s %d\n", 4*(level - 1), "", title, pgnum
        level -= gsub(/\)/, "")
        next
    }
' "$1"
