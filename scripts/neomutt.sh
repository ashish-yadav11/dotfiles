#!/bin/dash
termite --name=neomutt_Termite -e "dash -c 'stty -ixon; neomutt'"
pidof -s /usr/bin/neomutt >/dev/null 2>&1 || rm -rf /tmp/neomutt/
