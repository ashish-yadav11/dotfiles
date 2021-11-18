#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

output="$(curl -s -X POST -d "mode=191&username=ashishkumar.yadav&password=$(pass captive-portal/ashishkumar.yadav)&a=$(date +%s)000&producttype=1" http://192.168.1.3:8090/login.xml)"
if [ -z "$output" ] ; then
    $notify -t 2000 "Not connected to IISER network"
elif echo "$output" | grep -qv "Login failed" ; then
    $notify -t 2000 "Successfully logged into IISER captive portal"
else
    $notify -t 4000 -u critical "Could not log into IISER captive portal"
fi
