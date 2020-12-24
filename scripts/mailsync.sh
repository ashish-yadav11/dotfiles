#!/bin/dash
mbsync_channel=iiser
trash_folder="/home/ashish/.local/share/mail/iiser/[Gmail].Trash/"

# At max two instances of the script are allowed to run simultaneously,
# one syncing and one waiting for the other to finish syncing.

sigdsblocks 3 0
exec >/dev/null 2>&1 8>/tmp/mailsync.1.lock 9>/tmp/mailsync.2.lock
if ! flock -n 8 ; then
    flock -n 9 || exit
    flock 8
fi
time=$(date +%s)
if mbsync "$mbsync_channel" ; then
    find "$trash_folder" -newerct "@$time" -type f | mflag -S
    sigval=1
else
    sigval=2
fi
exec 8>/dev/null
notmuch new
flock -n 9 || sigdsblocks 3 "$sigval"
