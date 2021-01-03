#!/bin/dash
notmuch_search() {
    if ! output=$(notmuch search --output=messages "$@" 2>/dev/null) ; then
        notify-send -u critical -t 2000 NeoMutt "notmuch search failed"
        output=$(notmuch search --output=messages '*')
    elif [ -z "$output" ] ; then
        notify-send -t 2000 NeoMutt "no matching mails found"
        output=$(notmuch search --output=messages '*')
    fi
    echo "$output" | awk '/^id:/ {print "<"substr($0,4)">"}'
}

shift
case $1 in
    __MACRO__)
        if read -r arg 2>/dev/null </tmp/neomutt/notmuch.arg ; then
            notmuch_search --limit=500 -- "$arg"
            rm -f /tmp/neomutt/notmuch.arg
        else
            notmuch_search '*'
        fi
        ;;
    *)
        notmuch_search --limit=500 -- "$@"
        ;;
esac
