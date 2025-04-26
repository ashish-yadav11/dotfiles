#!/bin/dash
usageexit() {
    echo "Usage: playerctl play|pause|play-pause|next|previous|status" >&2
    exit 2
}

mprissend() {
    dbus-send --print-reply=literal --dest=org.python.mpriscustomdaemon \
        /org/python/mpriscustomdaemon "org.python.mpriscustomdaemon.$1" "string:$2"
}

case "$1" in
    play|pause|next|previous)
        mprissend doaction "$1" ;;
    play-pause)
        mprissend doaction toggle ;;
    status)
        mprissend query player ;;
    *)
        usageexit ;;
esac

