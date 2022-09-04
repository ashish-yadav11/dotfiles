#!/bin/dash
hotspot="/home/ashish/.scripts/hotspot_launch.sh"

while read -r dummy ; do
    clear
    $hotspot &
done
