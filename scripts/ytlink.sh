#!/bin/dash
musicdir=/media/storage/Music

path="$1"
filename="${path##*/}"

case "$path" in
    "$musicdir/"*)
        idp="${filename##*(}"
        id="${idp%)*}"
        if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
            url="https://music.youtube.com/watch?v=$id"
            echo -n "$url" | xsel -ib
        fi
        ;;
    *)
        idp="${filename##*[}"
        id="${idp%]*}"
        if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
            url="https://www.youtube.com/watch?v=$id"
            echo -n "$url" | xsel -ib
        fi
        ;;
esac
