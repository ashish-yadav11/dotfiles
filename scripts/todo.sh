#!/bin/dash
todo_file=/home/ashish/Documents/.todo

if [ "$#" = 0 ] ; then
    [ -f "$todo_file" ] && nl -b a "$todo_file"
    exit
fi
case "$1" in
    -e)
        [ -f "$todo_file" ] || touch "$todo_file"
        nvim "$todo_file"
        ;;
    -c)
        : >"$todo_file"
        ;;
    -r*)
        [ -f "$todo_file" ] || exit
        index="${1#-r}"
        index="${index:-"$2"}"
        if [ "$index" -gt 0 ] 2>/dev/null ; then
            sed -i "${index}d" "$todo_file"
        else
            nl -b a "$todo_file"
            read -r -p "Type index of the task to remove: " index
            [ "$index" -gt 0 ] 2>/dev/null &&
                sed -i "${index}d" "$todo_file"
        fi
        ;;
    *)
        echo "$*" >>"$todo_file"
        ;;
esac
