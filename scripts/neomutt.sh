#!/bin/dash
termite --name=neomutt_Termite -e "bash -c 'stty -ixon; neomutt'"
pidof -s /usr/bin/neomutt || rm -rf /tmp/neomutt-tmp/
