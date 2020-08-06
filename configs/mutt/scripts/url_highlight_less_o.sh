#!/bin/dash
export GREP_COLORS='ms=3;38;5;45'
grep --color=always -E -e '^' -e '\bhttps?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]' "$1" | less -R
