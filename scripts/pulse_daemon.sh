#!/bin/dash
lockfile="$XDG_RUNTIME_DIR/pulsedaemon.lock"

exec 9<>"$lockfile"
if ! flock -n 9 ; then
    echo "pulsedaemon: another instance already active, exiting!" >&2
    exit 2
fi

pactl subscribe |
    while IFS='' read -r event ; do
        case "$event" in
            *" sink "*) sigdsblocks 2 0 ;;
        esac
    done
