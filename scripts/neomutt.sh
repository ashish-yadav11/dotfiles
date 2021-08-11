#!/bin/dash
[ "$1" = scratch ] && options="-n neomutt-st"

st $options -e dash -c 'stty -ixon; neomutt'
pidof -sq /usr/bin/neomutt || rm -rf /tmp/neomutt/
