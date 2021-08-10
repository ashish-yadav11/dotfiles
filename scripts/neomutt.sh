#!/bin/dash
st -n neomutt-st -e dash -c 'stty -ixon; neomutt'
pidof -sq /usr/bin/neomutt || rm -rf /tmp/neomutt/
