#!/bin/dash
mkdir -p "/tmp/neomutt-tmp/html_in_browser/"
file="/tmp/neomutt-tmp/html_in_browser/$(basename "$1")"
rm -f "$file"
cp "$1" "$file"
setsid -f "$BROWSER" "$file" >/dev/null 2>&1
