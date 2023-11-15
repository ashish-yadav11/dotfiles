#!/bin/dash
ytmsclu_addjob="/home/ashish/.scripts/ytmsclu-addjob.sh"
notifyerror="notify-send -u critical -t 0 ytmsclu-history"

filename="${1##*/}"
idp="${filename##*(}"
id="${idp%)*}"
if [ "$idp" != "$filename" ] && [ "$id" != "$idp" ] ; then
    url="https://music.youtube.com/watch?v=$id"
    $ytmsclu_addjob "$url" "history"
else
    $notifyerror "Error: file name not in expected format!\n'$filename'"
    exit
fi
