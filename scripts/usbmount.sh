#!/bin/dash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}' \
         -dmenu -i -matching fuzzy -multi-select -no-custom "$@"
}

# external drives not mounted in the filesystem
drives0="$(lsblk -nrpo "name,type,uuid,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $4=="" && $3!="018a948a-679d-44ad-8b03-cfe509fd2f0e" && $3!="E802A7A802A77A68" {if ($5!="") {printf "%s (%s - %s)\n",$1,$5,$6} else {printf "%s (%s)\n",$1,$6}}')"

# external drives mounted in the filesystem
drives1="$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $3!="" && $3!="/" && $3!="/efi" && $3!="[SWAP]" && $3!="/media/storage" && $3!="/run/timeshift/backup" {if ($4!="") {printf "%s (%s - %s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}')"

mount() {
    if output="$(udisksctl mount --no-user-interaction -b "$1")" ; then
        notify-send -t 2000 " USB mounter" "$output"
    else
        notify-send -u critical " USB mounter" "Error mounting $1"
    fi
}

unmount() {
    if output="$(udisksctl unmount --no-user-interaction -b "$1")" ; then
        notify-send -t 2000 " USB mounter" "${output%.}"
    else
        notify-send -u critical " USB mounter" "Error unmounting $1\nResource might be busy"
    fi
}

askmount() {
    echo "$drives0" | menu -p Mount: |
        while IFS='' read -r chosen ; do
            mount "${chosen%% *}"
        done
}

askunmount() {
    echo "$drives1" | menu -p Unmount: |
        while IFS='' read -r chosen ; do
            unmount "${chosen%% *}"
        done
}

asktype() {
    M="$(echo "$drives0" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')"
    U="$(echo "$drives1" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')"

    echo "Mount: ${M%?}\nUnmount: ${U%?}" | menu -p "What to do?" |
        while IFS='' read -r chosen ; do
            case "$chosen" in
                M*)
                    case "$M" in
                        *s) mount "${drives0%% *}" ;;
                        *m) askmount ;;
                    esac
                    ;;
                U*)
                    case "$U" in
                        *s) unmount "${drives1%% *}" ;;
                        *m) askunmount ;;
                    esac
                    ;;
            esac
        done
}

if [ -n "$drives0" ] ; then
    if [ -z "$drives1" ] ; then
        askmount
    else
        asktype
    fi
else
    if [ -n "$drives1" ] ; then
        askunmount
    else
        notify-send -t 2000 " USB mounter" "No USB drive to mount or unmount"
    fi
fi
