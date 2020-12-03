#!/bin/dash
exec >/dev/null 2>&1

sigdsblocks 3 1

exec 8>/tmp/mailsync.1.lock
# Exit if some other instance of the script is running which hasn't
# crossed the pinging stage
flock -n 8 || exit

exec 9>/tmp/mailsync.2.lock
# Wait while some other instance of the script is running which has
# crossed the pinging stage
flock 9 || exit

if ping -c1 imap.gmail.com ; then
    exec 8>/dev/null
    sigdsblocks 3 -2
    time=$(date +%s)
    if mbsync iiser ; then
        trash_folder="/home/ashish/.local/share/mail/iiser/[Gmail].Trash/"

        find "$trash_folder" -newerct "@$time" -type f | mflag -S
        sigdsblocks 3 3
    else
        sigdsblocks 3 4
    fi
    notmuch new
else
    exec 8>/dev/null
    sigdsblocks 3 -5
fi
