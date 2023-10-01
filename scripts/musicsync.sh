#!/bin/dash
src=/media/storage/Music/
for dst in "$XDG_RUNTIME_DIR/mtp/"*"/Internal shared storage/Music" ; do
    testfile="$dst/0"
    if touch "$testfile" 2>/dev/null ; then
        rm -f "$testfile"
        rsync -avu --delete  -f"- */" -f"+ *" "$src" "$dst"
        exit 0
    fi
done
echo "Destination device not mounted!"
exit 1
