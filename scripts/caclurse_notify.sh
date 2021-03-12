#!/bin/dash
output=$(calcurse -n); output=${output#*\[}
h=${output%%:*}; output=${output#*:}
m=${output%%\]*}
title=${output#*\] }
case $output in [IMP][DAH][CTY]\ [1-4][1-9][12]\ -\ slot) exit ;; esac
t=$(( h * 60 + m ))
notify-send -t "$(( t * 60000 ))" Calcurse "Appointment in $t minute(s)\n$title"
