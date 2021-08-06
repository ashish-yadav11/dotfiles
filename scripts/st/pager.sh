#!/bin/sh
tmpfile="$(mktemp /tmp/st-XXXXXX)"
cat >"$tmpfile"
setsid -f st -e dash -c "nvim -c 'normal G' -R $tmpfile; rm -f $tmpfile"
