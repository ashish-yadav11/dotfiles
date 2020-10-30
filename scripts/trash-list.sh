#!/bin/dash
if [[ -z $1 ]] ; then
    /usr/bin/trash-list | sort
    return
fi
case $1 in
    --)
        /usr/bin/trash-list | sort | grep "${@:2}"
        ;;
    -n)
        /usr/bin/trash-list | sort -k3,3
        ;;
    -t)
        /usr/bin/trash-list | sort
        ;;
    *)
        /usr/bin/trash-list | sort | grep "$@"
        "$*" ;;
esac
