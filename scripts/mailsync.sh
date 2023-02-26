#!/bin/dash
mbsync_channel=iiser
timeout=300
trash_folder="/home/ashish/.local/share/mail/iiser/[Gmail].Trash"

lockfile1="$XDG_RUNTIME_DIR/mailsync.1.lock"
lockfile2="$XDG_RUNTIME_DIR/mailsync.2.lock"

# At max two instances of the script are allowed to run simultaneously,
# one syncing and one waiting for the other to finish syncing.

exec >/dev/null 2>&1 8<>"$lockfile1" 9<>"$lockfile2"

sigdsblocks 3 -1
if ! flock -n 8 ; then
    flock -n 9 || exit
    flock 8
fi
# Workaround for freezing issue of mbsync.
timeout "$timeout" mbsync "$mbsync_channel"
sigval="$?"
find "$trash_folder"/* -type f | mflag -S
notmuch new
flock -n 9 && sigdsblocks 3 "$sigval"
