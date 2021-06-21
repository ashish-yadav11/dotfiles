#!/bin/dash
mbsync_channel=iiser
trash_folder="/home/ashish/.local/share/mail/iiser/[Gmail].Trash"

lockfile1=/var/local/dsblocks/mailsync.1.lock
lockfile2=/var/local/dsblocks/mailsync.2.lock

# At max two instances of the script are allowed to run simultaneously,
# one syncing and one waiting for the other to finish syncing.

sigdsblocks 3 -1
exec >/dev/null 2>&1 8<>"$lockfile1" 9<>"$lockfile2"
if ! flock -n 8 ; then
    flock -n 9 || exit
    flock 8
fi
mbsync "$mbsync_channel"
sigval=$?
find "$trash_folder"/* -type f | mflag -S
notmuch new
flock -n 9 && sigdsblocks 3 "$sigval"
