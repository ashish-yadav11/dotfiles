#!/bin/bash
src=/media/storage/Music/
dst=( "$XDG_RUNTIME_DIR/mtp/RMX1831-9PLF7LKZKNFYLR5H-"*"/Internal shared storage/Music" )
if [[ -d "${dst[0]}" ]] ; then
    rsync -avu --delete  -f"- */" -f"+ *" "$src" "${dst[0]}"
else
    echo "Destination device not mounted!"
    exit 1
fi
