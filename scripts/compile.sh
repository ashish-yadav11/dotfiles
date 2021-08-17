#!/bin/dash
file="$1"
[ -f "$file" ] || { echo "Error: \"$file\" is not a valid file!"; exit ;}
filename="${file%.*}"
fileext="${file##*.}"
shift

optimize=0
error=1
run=0
case "$2" in *o*) optimize=1 ;; esac
case "$2" in *E*) error=0 ;; esac
case "$2" in *r*) run=1 ;; esac
[ "$#" -ge 2 ] && shift

case "$fileext" in
    c)
        [ "$error" = 1 ] && errarg="-Wall -Werror"
        [ "$optimize" = 1 ] && optarg="-O3"
        gcc -o "${filename}" $optarg $errarg "$@" "$file" || exit
        [ "$run" = 1 ] && exit
        ;;
    f90)
        [ "$error" = 1 ] && errarg="-W4"
        [ "$optimize" = 1 ] && optarg="-fast"
        f90 -o "${filename}" $optarg $errarg "$@" "$file" || exit
        [ "$run" = 1 ] && exit
        ;;
esac

case "$filename" in
    /*) "$filename" ;;
     *) "./$filename" ;;
esac
