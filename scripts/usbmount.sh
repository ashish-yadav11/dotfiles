#!/bin/dash
dmenu="dmenu -i -matching fuzzy -multi-select -no-custom"

# external drives not mounted in the filesystem
drives0=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $3=="" {if ($4!="") {printf "%s (%s - %s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}')

# external drives mounted in the filesystem
drives1=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '$2=="part" && $3!="" && $3!="/" && $3!="/efi" && $3!="[SWAP]" && $3!="/media/backup" && $3!="/media/storage" && $3!="/run/timeshift/backup" {if ($4!="") {printf "%s (%s - %s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}')

usbmount() {
    echo "$drives0" | $dmenu -p "Which drive(s) to mount?" |
        while read -r chosen ; do
            drive=${chosen%% *}
            if output=$(udisksctl mount -b "$drive") ; then
                notify-send -t 2000 " USB mounter" "$output"
            else
                notify-send -u critical " USB mounter" "Error mounting $drive"
            fi
        done
}

usbunmount() {
    echo "$drives1" | $dmenu -p "Which drive(s) to unmount?" |
        while read -r chosen ; do
            drive=${chosen%% *}
            if output=$(udisksctl unmount -b "$drive") ; then
                notify-send -t 2000 " USB mounter" "${output%.}"
            else
                notify-send -u critical " USB mounter" "Error unmounting $drive"
            fi
        done
}

asktype() {
    M=$(echo "$drives0" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')
    U=$(echo "$drives1" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')

    echo "Mount: ${M%?}\nUnmount: ${U%?}" | $dmenu -p "What to do?" |
        while read -r chosen ; do
            case $chosen in
            M*)
                case $M in
                *s)
                    drive=${drives0%% *}
                    if output=$(udisksctl mount -b "$drive") ; then
                        notify-send -t 2000 " USB mounter" "$output"
                    else
                        notify-send -u critical " USB mounter" "Error mounting $drive"
                    fi
                    ;;
                *m)
                    usbmount
                    ;;
                esac
                ;;
            U*)
                case $U in
                *s)
                    drive=${drives1%% *}
                    if output=$(udisksctl unmount -b "$drive") ; then
                        notify-send -t 2000 " USB mounter" "${output%.}"
                    else
                        notify-send -u critical " USB mounter" "Error unmounting $drive"
                    fi
                    ;;
                *m)
                    usbunmount
                    ;;
                esac
                ;;
            esac
        done
}

if [ -n "$drives0" ] ; then
    if [ -z "$drives1" ] ; then
        usbmount
    else
        asktype
    fi
else
    if [ -n "$drives1" ] ; then
        usbunmount
    else
        notify-send -t 2000 " USB mounter" "No USB drive to mount or unmount"
    fi
fi
