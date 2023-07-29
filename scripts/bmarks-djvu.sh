#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    BEGIN {
        print "(bookmarks"
        plevel = -1
    }
    {
        spc = $0
        sub(/[^ ].*/, "", spc)
        clevel = length(spc) / 4 + 1
        closebracket(clevel, plevel)
        printtitle(clevel)
        plevel = clevel
        next
    }
    END {
        closebracket(0, plevel)
    }

    function printtitle(clevel) {
        printf "%*s(\"%s", clevel, "", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\"\n %*s\"#%s\"", clevel, "", $NF

    }
    function closebracket(clevel, plevel) {
        i = plevel - clevel
        while (i-- >= 0) {
            printf " )"
        }
        if (i >= -2) {
            printf "\n"
        }
    }
' "$1"
