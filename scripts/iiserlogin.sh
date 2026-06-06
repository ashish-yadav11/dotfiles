#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

GEN204URL="http://clients3.google.com/generate_204"
case "$(curl -s -m1 -o /dev/null -w '%{http_code}' -L "$GEN204URL" || echo 000)" in
    000)
        $notify -t 2000 "Curl check for IISER captive portal failed!"
        exit
        ;;
    204)
        if [ "$1" != logout ] ; then
            $notify -h int:transient:1 -t 2000 "Already logged in IISER captive portal!"
            exit
        fi
        ;;
esac

username="$(pass captive-portal/username)"
password="$(pass captive-portal/password)"

PRODUCTTYPE=0
USERAGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100 Safari/537.36"

sendloginrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "https://firewall.iiserpune.ac.in:8090/login.xml" \
        --data-urlencode "mode=191" \
        --data-urlencode "username=$username" \
        --data-urlencode "password=$password" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

sendliverequest() {
    lu=$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')
    curl -k -s -m 3 -A "$USERAGENT" -G \
        --url "https://firewall.iiserpune.ac.in:8090/live" \
        --data-urlencode "mode=192" \
        --data-urlencode "username=$lu" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

sendlogoutrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "https://firewall.iiserpune.ac.in:8090/logout.xml" \
        --data-urlencode "mode=193" \
        --data-urlencode "username=$username" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}
if [ "$1" = logout ] ; then
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

output="$(sendloginrequest)" || notconnected
if printf '%s' "$output" | grep -qvF "Login failed" ; then
    loginsuccess
else
    loginfailed
fi

while true ; do
    output="$(sendliverequest)" || break
    printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[live_off]]></ack>" && break
    printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[ack]]></ack>" && continue
    output="$(sendloginrequest)" || break
    printf '%s' "$output" | grep -qvF "Login failed" || loginfailed
    sleep 180
done
