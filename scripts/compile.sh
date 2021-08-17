#!/bin/dash
file="$1"
filename="${file%.*}"
fileext="${file##*.}"
arg="$2"
shift 2

optimize=0
error=1
case "$arg" in O?|?O) optimize=1 ;; esac
case "$arg" in e?|?e) error=0 ;; esac

case "$fileext" in
    c)
        [ "$error" = 1 ] && errarg="-Wall -Werror"
        [ "$optimize" = 1 ] && optarg="-O3"
        gcc -o "${filename}" $optarg $errarg "$@" "$file"
        ;;
    f90)
        [ "$error" = 1 ] && errarg="-W4"
        [ "$optimize" = 1 ] && optarg="-fast"
        f90 -o "${filename}" $optarg $errarg "$@" "$file"
        ;;
esac
