#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

gawk '
    BEGIN {
        print "(bookmarks"
    }
    /^BookmarkTitle: / {
        title = $0
        sub(/^BookmarkTitle: /, "", title)
    }
    /^BookmarkLevel: / {
        if ($2 == 1) {
            if (flag != 0) {
                printf " )\n"
            }
            flag = 1
            printf " (\"%s\"\n", title
        } else if ($2 == 2) {
            flag = 2
            printf "\n  (\"%s\"\n", title
        }
        next
    }
    /^BookmarkPageNumber: / {
        if (flag == 1) {
            printf "  \"#%s\"", $2
        } else if (flag == 2) {
            printf "   \"#%s\" )", $2
        }
    }
    END {
        if (flag == 1) {
            printf " ) )\n"
        } else if (flag == 2) {
            printf " ) ) )\n"
        }
    }
' "$1"
