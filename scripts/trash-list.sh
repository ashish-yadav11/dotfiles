#!/bin/dash
if [ -z "$1" ] ; then
    /usr/bin/trash-list | sort
else
    case $1 in
        --)
            shift
            /usr/bin/trash-list | sort | grep "$@"
            ;;
        -n)
            /usr/bin/trash-list | sort -k3,3
            ;;
        -t)
            /usr/bin/trash-list | sort
            ;;
        *)
            /usr/bin/trash-list | sort | grep "$@"
            ;;
    esac
fi
