#!/bin/bash
skedda_list="/home/ashish/.scripts/skedda-list.py"
skedda_book="/home/ashish/.scripts/skedda-book.py"
skedda_delete="/home/ashish/.scripts/skedda-delete.py"

logfile="/tmp/skedda-log.json"
histfile="/tmp/skedda-hist.json"
idfile="/tmp/skedda-id.tmp"
cookiefile="/home/ashish/.cache/skedda.cookies"

username="$(pass "skedda/username")"
password="$(pass "skedda/$username")"
logindata='{
  "login": {
    "username": "'"$username"'",
    "password": "'"$password"'",
    "rememberMe": true,
    "arbitraryerrors": null
  }
}'

nidlesec=600
eidlesec=600

scurlb() {
    curl -sS -b "$cookiefile" "$@"
}

scurlc() {
    curl -sS -b "$cookiefile" -c "$cookiefile" "$@"
}

curlfailed() {
    echo -e "Error: curl failed! exiting..."
    exit
}

curlwait() {
    echo "Warning: curl failed!"
    waitsleep "$eidlesec"
}

waitsleep() {
    interrupted=n
    read -r -t "$1" d && interrupted=y
}

cookieexpired() {
    [[ -f "$cookiefile" ]] || return 0
    ret=0
    {
        read -r d; read -r d; read -r d; read -r d
        while read -r d d d d time d ; do
            if [[ "$time" == 0 || "$(date +%s)" -lt "$(( time - 60 ))" ]] ; then
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
    scurlc -H "X-Skedda-Requestverificationtoken: $vftkn" -H "Content-Type: application/json" -X POST -d "$logindata" 'https://app.skedda.com/logins' || curlfailed
    scurlc -H "X-Skedda-Requestverificationtoken: $vftkn" -X POST --data-urlencode "username=$username&password=$password&ReturnUrl=" 'https://app.skedda.com/account/applogin' || curlfailed
    echo -e "\nLogin successful.\n"
}

list() {
    cookieexpired && login
    output="$(scurlb 'https://sportsiiserp.skedda.com/booking')" || curlfailed
    if ! vftkn="$(printf "%s" "$output" | grep RequestVerificationToken)" ; then
        login
        vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || curlfailed
    fi

    vftkn="${vftkn#*value=\"}"
    vftkn="${vftkn%\"*}"
    if (( 10#$(date '+%H') >= 21 )) ; then
        curd="$(date -d '+1 day' '+%Y-%m-%d')"
    else
        curd="$(date '+%Y-%m-%d')"
    fi
    ntnd="$(date -d '+2 day' '+%Y-%m-%d')"
    { scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" "https://sportsiiserp.skedda.com/bookingslists?end=${ntnd}T23%3A59%3A59.999&start=${curd}T00%3A00%3A00" | jq >"$logfile" ;} || curlfailed

    if [[ "$1" == "delete" ]] ; then
        $skedda_delete "$logfile" "$idfile" || exit
        read -r id <"$idfile"
        rm -rf "$idfile"
        echo "Removing the booking..."
        scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" -X DELETE "https://sportsiiserp.skedda.com/bookings/$id" || curlfailed
        echo -e "\nRemoval successful.\n"
    else
        $skedda_list "$logfile"
    fi
}

loop() {
#   gsid="$(pass skedda/gs.id)"
#   prvgsbook=0
    rm -f "$histfile" # reset history on start
    while true ; do
        cookieexpired && login
        output="$(scurlb 'https://sportsiiserp.skedda.com/booking')" || { curlwait; continue ;}
        if ! vftkn="$(printf "%s" "$output" | grep RequestVerificationToken)" ; then
            login
            vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || { curlwait; continue ;}
        fi

        vftkn="${vftkn#*value=\"}"
        vftkn="${vftkn%\"*}"
        if (( 10#$(date '+%H') >= 22 )) ; then
            curd="$(date -d '+1 day' '+%Y-%m-%d')"
        else
            curd="$(date '+%Y-%m-%d')"
        fi
        ntnd="$(date -d '+2 day' '+%Y-%m-%d')"
        if [[ -n "$prvcurd" && "$curd" != "$prvcurd" ]] ; then
            prvparsed_c="$($skedda_list <(jq "{\"bookings\" : (.bookings[:1] + (.bookings[1:] | map(select(.start >= \"${curd}T00:00:00\")))), \"venueusers\" : .venueusers}" "$logfile"))"
            prvbookings="$(jq ".bookings[1:] | map(select(.start >= \"${curd}T00:00:00\"))" "$logfile")"
#           prvgsbook="$(printf "%s" "$prvbookings" | grep -B13 "$gsid")"
        fi
        prvcurd="$curd"
        output="$(scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" "https://sportsiiserp.skedda.com/bookingslists?end=${ntnd}T23%3A59%3A59.999&start=${curd}T00%3A00%3A00")" || { curlwait; continue ;}
        printf "%s" "$output" | jq >"$logfile"

        curparsed="$($skedda_list "$logfile" "$histfile")"
        curparsed_c="${curparsed//\*$'\n'/$'\n'}"
        curparsed_c="${curparsed_c%\*}"
        if [[ "$curparsed_c" != "$prvparsed_c" ]] ; then
            case "$1" in clean) printf "\ec" ;; *) clear ;; esac
            printf "%s\n" "$curparsed"
            case "$*" in *silent) : ;; *) printf '\a' ;; esac
            prvparsed_c="$curparsed_c"
        elif [[ "$interrupted" == y ]] ; then
            case "$1" in clean) printf "\ec" ;; *) clear ;; esac
            printf "%s\n" "$curparsed"
        fi

#       curgsbook="$(printf "%s" "$output" | jq '.bookings[1:]' | grep -B13 "$gsid")"
#       [[ "$prvgsbook" != 0 && "$curgsbook" != "$prvgsbook" ]] && telegram 'Sugar!'
#       prvgsbook="${curgsbook}"

        waitsleep "$nidlesec"
    done
}

book() {
    if [[ "$#" != 2 ]] ; then
        echo 'Usage: skedda book <slot {1:1}> <time {,7|.8|/7}>'
        exit 2
    fi
    jsondata="$($skedda_book "$1" "$2")" || exit

    cookieexpired && login
    output="$(scurlb 'https://sportsiiserp.skedda.com/booking')" || curlfailed
    if ! vftkn="$(printf "%s" "$output" | grep RequestVerificationToken)" ; then
        login
        vftkn="$(scurlb 'https://sportsiiserp.skedda.com/booking' | grep RequestVerificationToken)" || curlfailed
    fi

    vftkn="${vftkn#*value=\"}"
    vftkn="${vftkn%\"*}"
    echo "Booking the given slot..."
    scurlb -H "X-Skedda-Requestverificationtoken: $vftkn" -X POST -H "Content-Type: application/json" -d "$jsondata" 'https://sportsiiserp.skedda.com/bookings' || curlfailed
    echo -e "\nBooking successful.\n"
}

case "$1" in
    list) list ;;
    book) shift; book "$@" && list ;;
    book-quiet) shift; book "$@" ;;
    delete) list delete && list ;;
    delete-quiet) list delete quiet ;;
    loop) shift; loop "$@" ;;
    login) login ;;
    *) echo "Incorrect usage!"; exit 2 ;;
esac
