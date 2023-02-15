#!/bin/dash
hotspot="sudo /home/ashish/.scripts/hotspot.sh"
hotspot_launch="/home/ashish/.scripts/hotspot_launch.sh"

colnrm='\033[0;36m'
colwrn='\033[1;31m'
coldef='\033[0m'

empty_prompt() {
    clear
    printf "${colnrm}Press enter to continue:${coldef} "
}

case "$(tr '\0' '%' <"/proc/$PPID/cmdline")" in
    "login -- $USER"%*)
        :
        ;;
    *)
        printf "${colwrn}Parent process of the program is not a login shell. Do you still want to continue?${coldef} [N/y]: "
        read -r input
        [ "$input" != y ] && [ "$input" != Y ] && exit
        ;;
esac

empty_prompt
while read -r dummy ; do
    if [ -n "$($hotspot list-running)" ] ; then
        clear
        printf "${colwrn}Hotspot is active, kill it?${coldef} [y/N]: "
        read -r input
        [ "$input" != y ] && [ "$input" != Y ] && { empty_prompt; continue ;}
    else
        clear
        printf "${colnrm}Hotspot is inactive, launch it?${coldef} [Y/n]: "
        read -r input
        { [ "$input" = n ] || [ "$input" = N ] ;} && { empty_prompt; continue ;}
    fi
    clear
    $hotspot_launch &
done
