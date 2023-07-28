#!/bin/dash
[ -e "$1" ] || { echo "Usage: $0 bmarks-file"; exit ;}

awk '
    BEGIN {
        print "(bookmarks"
        plevel = -1
    }
    /^            / {
        closebracket(4, plevel)
        printtitle(4)
        plevel = 4
        next
    }
    /^        / {
        closebracket(3, plevel)
        printtitle(3)
        plevel = 3
        next
    }
    /^    / {
        closebracket(2, plevel)
        printtitle(2)
        plevel = 2
        next
    }
    {
        closebracket(1, plevel)
        printtitle(1)
        plevel = 1
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
