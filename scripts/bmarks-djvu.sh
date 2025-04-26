#!/bin/dash
usageexit() {
    echo "Usage: $0 [-s <shift>] bmarks-file" 2>/dev/null
    exit 2
}
case "$1" in
    -s*)
        if [ "$1" = "-s" ] ; then
            s="$2"; file="$3"
        else
            s="${1#-s}"; file="$2"
        fi ;;
    *)
        s=0; file="$1" ;;
esac
{ [ "$s" -eq "$s" ] 2>/dev/null && [ -e "$file" ] ;} || usageexit

awk '
    BEGIN {
        print "(bookmarks"
        plevel = -1
    }
    {
        gsub(/"/, "\\\"")
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
        printf "\"\n %*s\"#%s\"", clevel, "", $NF'"+$s"'

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
' "$file"
