#!/bin/bash
hotspot="sudo /home/ashish/.scripts/hotspot.sh"
hotspot_launch="/home/ashish/.scripts/hotspot_launch.sh"

colnrm='\033[0;36m'
colwrn='\033[1;31m'
coldef='\033[0m'

empty_prompt() {
    clear
    echo -ne "${colnrm}Press [enter] to continue:${coldef} "
}

if [[ ! "$(tr '\0' '%' <"/proc/$PPID/cmdline")" =~ "login -- $USER"%* ]] ; then
    echo -ne "${colwrn}Parent process of the program is not a login shell. "
    echo -ne "Do you still want to continue?${coldef} [N/y]: "
    read -r input
    [ "$input" != y ] && [ "$input" != Y ] && exit
fi

empty_prompt
while read -r dummy ; do
    if [[ -n "$($hotspot list-running)" ]] ; then
        clear
        echo -ne "${colwrn}Hotspot is active, kill it?${coldef} [y/N]: "
        read -rt 5 input || { empty_prompt; continue ;}
        [[ "$input" != y && "$input" != Y ]] && { empty_prompt; continue ;}
    else
        clear
        echo -ne "${colnrm}Hotspot is inactive, launch it?${coldef} [Y/n]: "
        read -rt 5 input || { empty_prompt; continue ;}
        [[ "$input" = n || "$input" = N ]] && { empty_prompt; continue ;}
    fi
    clear
    $hotspot_launch &
done
