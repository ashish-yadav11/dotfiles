#!/bin/dash
mkdir -p "/tmp/neomutt-tmp/edit_pdf/"
file="/tmp/neomutt-tmp/edit_pdf/$(basename "$1")"
rm -f "$file"
cp "$1" "$file"
setsid -f okular "$file" >/dev/null 2>&1
