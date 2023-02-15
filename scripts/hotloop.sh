#!/bin/dash
hotspot="sudo /home/ashish/.scripts/hotspot.sh"
hotspot_launch="/home/ashish/.scripts/hotspot_launch.sh"

colblu='\033[1;34m'
colred='\033[1;31m'
coldef='\033[0m'

case "$(tr '\0' '%' <"/proc/$PPID/cmdline")" in
    "login -- $USER"%*)
        :
        ;;
    *)
        printf "${colred}Parent process of the program is not a login shell. Do you still want to continue?${coldef} [N/y]: "
        read -r input
        [ "$input" != y ] && [ "$input" != Y ] && exit
        ;;
esac
clear

while read -r dummy ; do
    if [ -n "$($hotspot list-running)" ] ; then
        clear
        printf "${colred}Hotspot is active, kill it?${coldef} [y/N]: "
        read -r input
        [ "$input" != y ] && [ "$input" != Y ] && { clear; continue ;}
    else
        clear
        printf "${colblu}Hotspot is inactive, launch it?${coldef} [Y/n]: "
        read -r input
        { [ "$input" = n ] || [ "$input" = N ] ;} && { clear; continue ;}
    fi
    clear
    $hotspot_launch &
done
