#!/bin/dash
mkdir -p "/tmp/neomutt/html_in_browser"
file="/tmp/neomutt/html_in_browser/$(basename "$1")"
rm -f "$file"
cp "$1" "$file"
setsid -f "$BROWSER" "$file" >/dev/null 2>&1
