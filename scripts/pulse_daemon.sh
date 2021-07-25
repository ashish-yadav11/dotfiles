#!/bin/dash
pactl subscribe |
    while IFS='' read -r event ; do
        case "$event" in
            *" sink "*) sigdsblocks 2 ;;
        esac
    done
