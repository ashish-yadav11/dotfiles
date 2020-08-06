#!/bin/dash
# helps open a file with xdg-open from mutt in a external program without weird side effects
mkdir -p "/tmp/neomutt-tmp/open_file/"
file="/tmp/neomutt-tmp/open_file/$(basename "$1")"
rm -f "$file"
cp "$1" "$file"
setsid -f xdg-open "$file" >/dev/null 2>&1
