#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    BEGIN {
        print "(bookmarks"
    }
    /^    / {
        flag = 2
        printf "\n  (\"%s", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\"\n   \"#%s\" )", $NF
        next
    }
    {
        if (flag != 0) {
            printf " )\n"
        }
        flag = 1
        printf " (\"%s", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\"\n  \"#%s\"", $NF
        next
    }
    END {
        if (flag == 1) {
            printf " ) )\n"
        } else if (flag == 2) {
            printf " ) ) )\n"
        }
    }
' "$1"
