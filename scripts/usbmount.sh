#!/bin/dash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -i -matching fuzzy -multi-select -no-custom"

# external drives not mounted in the filesystem
drives0=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $3=="" {if ($4!="") {printf "%s (%s - %s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}')

# external drives mounted in the filesystem
drives1=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $3!="" && $3!="/" && $3!="/efi" && $3!="[SWAP]" && $3!="/media/backup" && $3!="/media/storage" && $3!="/run/timeshift/backup" {if ($4!="") {printf "%s (%s - %s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}')

mount() {
    if output=$(udisksctl mount -b "$1") ; then
        notify-send -t 2000 " USB mounter" "$output"
    else
        notify-send -u critical " USB mounter" "Error mounting $1"
    fi
}

unmount() {
    if output=$(udisksctl unmount -b "$1") ; then
        notify-send -t 2000 " USB mounter" "${output%.}"
    else
        notify-send -u critical " USB mounter" "Error unmounting $1"
    fi
}

askmount() {
    echo "$drives0" | $menu -p "Which drive(s) to mount?" |
        while IFS='' read -r chosen ; do
            mount "${chosen%% *}"
        done
}

askunmount() {
    echo "$drives1" | $menu -p "Which drive(s) to unmount?" |
        while IFS='' read -r chosen ; do
            unmount "${chosen%% *}"
        done
}

asktype() {
    M=$(echo "$drives0" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')
    U=$(echo "$drives1" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')

    echo "Mount: ${M%?}\nUnmount: ${U%?}" | $menu -p "What to do?" |
        while IFS='' read -r chosen ; do
            case $chosen in
                M*)
                    case $M in
                        *s) mount "${drives0%% *}" ;;
                        *m) askmount ;;
                    esac
                    ;;
                U*)
                    case $U in
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
