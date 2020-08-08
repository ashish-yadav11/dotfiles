#!/bin/dash
mkdir -p "/tmp/neomutt/edit_image"
file="/tmp/neomutt/edit_image/$(basename "$1")"
rm -f "$file"
cp "$1" "$file"
setsid -f gimp "$file" >/dev/null 2>&1
