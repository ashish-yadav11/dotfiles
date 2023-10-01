#!/bin/bash
src=/media/storage/Music/
dst=( "$XDG_RUNTIME_DIR/mtp/"*"/Internal shared storage/Music" )
testfile="${dst[0]}/0"
if touch "$testfile" 2>/dev/null ; then
    rm -f "$testfile"
    rsync -avu --delete  -f"- */" -f"+ *" "$src" "${dst[0]}"
else
    echo "Destination device not mounted!"
    exit 1
fi
