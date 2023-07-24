#!/bin/dash
skedda_list="/home/ashish/.scripts/skedda-list.py"
skedda_book="/home/ashish/.scripts/skedda-book.py"
skedda_delete="/home/ashish/.scripts/skedda-delete.py"

logfile="/tmp/skedda-log.json"
idfile="/tmp/skedda-id.tmp"
loginfile="/home/ashish/.config/skedda/login.json"
cookiefile="/home/ashish/.cache/skedda.cookies"

username="ashishkumar.yadav@students.iiserpune.ac.in"
password="$(pass "skedda/$username")"

nidlesec=600
eidlesec=600

scurlb() {
    curl -sS -b "$cookiefile" "$@"
}

scurlc() {
    curl -sS -b "$cookiefile" -c "$cookiefile" "$@"
}

curlfailed() {
    echo "Error: curl failed! exiting..."
    exit
}

curlwait() {
    echo "Warning: curl failed! sleeping till next cycle..."
    sleep "$eidlesec"
}

cookieexpired() {
    [ -f "$cookiefile" ] || return 0
    ret=0
    {
        read -r d; read -r d; read -r d; read -r d
        while read -r d d d d time d ; do
            if [ "$time" = 0 ] || [ "$(date +%s)" -lt "$(( time - 60 ))" ] ; then
                ret=1
            else
                return 0
            fi
        done
    } <"$cookiefile"
    return "$ret"
}

login() {
    echo "Logging in..."
    : >"$cookiefile"
    vftkn="$(scurlc 'https://app.skedda.com/account/login' | grep 'RequestVerificationToken')" || curlfailed
    vftkn="${vftkn#*value=\"}"
    vftkn="${vftkn%\"*}"
    jsondata="$(jq ".login.password=\"$password\"" "$loginfile")"
    scurlc -H "X-Skedda-Requestverificationtoken: $vftkn" -H "Content-Type: application/json" -X POST -d "$jsondata" 'https://app.skedda.com/logins' || curlfailed
    scurlc -H "X-Skedda-Requestverificationtoken: $vftkn" -X POST --data-urlencode "username=$username&password=$password&ReturnUrl=" 'https://app.skedda.com/account/applogin' || curlfailed
    echo "\nLogin successful.\n"
}

list() {
    cookieexpired && login
    vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || curlfailed
    vftkn="${vftkn#*value=\"}"
    vftkn="${vftkn%\"*}"
    if [ "$(date '+%H')" -ge 21 ] ; then
        curd="$(date -d '+1 day' '+%Y-%m-%d')"
    else
        curd="$(date '+%Y-%m-%d')"
    fi
    ntnd="$(date -d '+2 day' '+%Y-%m-%d')"
    { scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" "https://sportsiiserp.skedda.com/bookingslists?end=${ntnd}T23%3A59%3A59.999&start=${curd}T00%3A00%3A00" | jq >"$logfile" ;} || curlfailed
    if [ "$1" = delete ] ; then
        $skedda_delete "$logfile" "$idfile" || exit
        read -r id <"$idfile"
        rm -rf "$idfile"
        echo "Removing the booking..."
        scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" -X DELETE "https://sportsiiserp.skedda.com/bookings/$id" || curlfailed
        echo "\nRemoval successful.\n"
    else
        $skedda_list "$logfile"
    fi
}

loop() {
    gsid="$(pass skedda/gs.id)"
    srid="$(pass skedda/sr.id)"
    while true ; do
        cookieexpired && login
        vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || { curlwait; continue ;}
        vftkn="${vftkn#*value=\"}"
        vftkn="${vftkn%\"*}"
        if [ "$(date '+%H')" -ge 22 ] ; then
            curd="$(date -d '+1 day' '+%Y-%m-%d')"
        else
            curd="$(date '+%Y-%m-%d')"
        fi
        ntnd="$(date -d '+2 day' '+%Y-%m-%d')"
        output="$(scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" "https://sportsiiserp.skedda.com/bookingslists?end=${ntnd}T23%3A59%3A59.999&start=${curd}T00%3A00%3A00")" || { curlwait; continue ;}
        printf "%s" "$output" | jq >"$logfile"

        curparsed="$($skedda_list "$logfile")"
        if [ "$curparsed" != "$prvparsed" ] ; then
            clear
            printf "%s\n\a" "$curparsed"
            prvparsed="$curparsed"
        fi
        curgsbook="$(printf "%s" "$output" | jq '.bookings[1:]' | grep -B13 "$gsid")"
        cursrbook="$(printf "%s" "$output" | jq '.bookings[1:]' | grep -B13 "$srid")"
        [ -n "$prvgsbook" ] && [ "$curgsbook" != "$prvgsbook" ] && telegram 'Sugar!'
        [ -n "$prvsrbook" ] && [ "$cursrbook" != "$prvsrbook" ] && telegram 'Raspberry!'
        prvgsbook="$curgsbook"
        prvsrbook="$cursrbook"
        sleep "$nidlesec"
    done
}

book() {
    if [ "$#" != 2 ] ; then
        echo 'Usage: skedda book <slot {1:1}> <time {,7|.8|/7}>'
        exit 2
    fi
    jsondata="$($skedda_book "$1" "$2")"

    cookieexpired && login
    vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || curlfailed
    vftkn="${vftkn#*value=\"}"
    vftkn="${vftkn%\"*}"
    echo "Booking the given slot..."
    scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" -X POST -H "Content-Type: application/json" -d "$jsondata" 'https://sportsiiserp.skedda.com/bookings' || curlfailed
    echo "\nBooking successful.\n"
}

case "$1" in
    list) list ;;
    book) shift; book "$@" && list ;;
    book-quiet) shift; book "$@" ;;
    delete) list delete && list ;;
    delete-quiet) list delete quiet ;;
    loop) loop ;;
    *) echo "Incorrect usage!"; exit 2 ;;
esac
