#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

username="$(pass captive-portal/username)"
password="$(pass captive-portal/password)"

captiveportalsite="https://firewall.iiserpune.ac.in:8090"
liveinterval=180
daemoninterval=7200
pingsite="cloudflare.com"

PRODUCTTYPE=0
USERAGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100 Safari/537.36"

sendloginrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "$captiveportalsite/login.xml" \
        --data-urlencode "mode=191" \
        --data-urlencode "username=$username" \
        --data-urlencode "password=$password" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

sendliverequest() {
    lu=$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')
    curl -k -s -m 3 -A "$USERAGENT" -G \
        --url "$captiveportalsite/live" \
        --data-urlencode "mode=192" \
        --data-urlencode "username=$lu" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

sendlogoutrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "$captiveportalsite/logout.xml" \
        --data-urlencode "mode=193" \
        --data-urlencode "username=$username" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}
if [ "$1" = "logout" ] ; then
    sendlogoutrequest
    exit
fi

notconnected() {
    $notify -h int:transient:1 -t 2000 "Not connected to IISER network"
    exit
}

loginsuccess() {
    $notify -h int:transient:1 -t 2000 "Successfully logged into IISER captive portal"
}

loginfailed() {
    $notify -t 4000 -u critical "Could not log into IISER captive portal"
    exit
}

sendlogoutrequest # to reset log out time on the server
output="$(sendloginrequest)" || notconnected
if printf '%s' "$output" | grep -qvF "Login failed" ; then
    loginsuccess
else
    loginfailed
fi
[ "$1" = "oneshot" ] && exit

while true ; do
    output="$(sendliverequest)" || break
    if printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[live_off]]></ack>" ; then
        [ "$1" != "daemon" ] && exit
        iface="$(ip route show default)"
        iface="${iface#*dev }"
        iface="${iface%% proto*}"
        while true ; do
            sleep "$daemoninterval"
            # wait for network inactivity for relogin, as it is an intrusive action
            # also check if the system has been logged out just in case, using ping
            lo=1
            while true ; do
                IFS='' read -r rx1 <"/sys/class/net/$iface/statistics/rx_bytes"
                IFS='' read -r tx1 <"/sys/class/net/$iface/statistics/tx_bytes"
                sleep 4
                IFS='' read -r rx2 <"/sys/class/net/$iface/statistics/rx_bytes"
                IFS='' read -r tx2 <"/sys/class/net/$iface/statistics/tx_bytes"
                [ "$(( rx2 - rx1 + tx2 - tx1 ))" -lt 2000 ] && break
                ping -q -c1 -W1 "$pingsite" >/dev/null 2>&1 || { lo=0; break ;}
            done
            [ "$lo" = 1 ] && sendlogoutrequest # to reset log out time on the server
            output="$(sendloginrequest)" || exit
            printf '%s' "$output" | grep -qvF "Login failed" || exit
        done
    fi
    if printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[ack]]></ack>" ; then
        sleep "$liveinterval"
        continue
    fi
    output="$(sendloginrequest)" || break
    printf '%s' "$output" | grep -qvF "Login failed" || loginfailed
done
