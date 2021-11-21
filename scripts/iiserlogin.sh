#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

sendloginrequest() {
    curl -s -X POST -d "mode=191&username=ashishkumar.yadav&password=$(pass captive-portal/ashishkumar.yadav)&a=$(date +%s)000&producttype=1" http://192.168.1.3:8090/login.xml
}

sendliverequest() {
    curl -s "http://192.168.1.3:8090/live?mode=192&username=ashishkumar.yadav&a=$(date +%s)000&producttype=1"
}

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
if echo "$output" | grep -qvF "Login failed" ; then
    loginsuccess
else
    loginfailed
fi

while true ; do
    output="$(sendliverequest)" || break
    echo "$output" | grep -qF "<ack><![CDATA[live_off]]></ack>" && break
    echo "$output" | grep -qF "<ack><![CDATA[ack]]></ack>" && continue
    output="$(sendloginrequest)" || break
    echo "$output" | grep -qvF "Login failed" || loginfailed
    sleep 180
done