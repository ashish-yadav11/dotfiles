#!/bin/dash
file="$1"
[ -f "$file" ] || { echo "Error: \"$file\" is not a valid file!"; exit ;}
filename="${file%.*}"
fileext="${file##*.}"
case "$fileext" in
    c) compiler=gcc ;;
    f[0-9][0-9]) compiler=gfortran ;;
    *) echo "Error: file extension \"$fileext\" is not supported!"; exit ;;
esac

errarg="-Wall -Wextra"
optarg=""
case "$2" in *o*) optarg="-O3" ;; esac
case "$2" in *E*) errarg="" ;; esac
case "$2" in *r*) run=1 ;; esac

shift "$(( $# < 2 ? $# : 2 ))"
"$compiler" -o "$filename" $optarg $errarg "$@" "$file" || exit
[ -n "$run" ] || exit

case "$filename" in
    /*) "$filename" ;;
     *) "./$filename" ;;
esac
