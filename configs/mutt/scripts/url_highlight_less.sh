#!/bin/dash
grep --color=always -E -e '^' -e '\bhttps?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]' "$1" | less -R
