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
    {
        spc = $0
        sub(/[^ ].*/, "", spc)
        level = length(spc) / 4 + 1
        printf "BookmarkBegin\nBookmarkTitle: %s", $1
        for (f=2; f<NF; f++) {
            printf " %s", $f
        }
        printf "\nBookmarkLevel: %s\nBookmarkPageNumber: %s\n", level, $NF'"+$s"'
    }
' "$file"
