#!/bin/dash
dmenu_command="dmenu -i -matching fuzzy -multi-select -no-custom"

drives_to_mount=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '{if ($2=="part" && $3=="") {if ($4!="") {printf "%s (%s-%s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}}')

drives_to_unmount=$(lsblk -nrpo "name,type,mountpoint,label,size" | awk -F'[ ]' '{if ($2=="part" && $3!="" && $3!="/" && $3!="/efi" && $3!="[SWAP]" && $3!="/media/backup" && $3!="/media/storage") {if ($4!="") {printf "%s (%s-%s)\n",$1,$4,$5} else {printf "%s (%s)\n",$1,$5}}}')

usbmount() {
    echo "$drives_to_mount" | $dmenu_command -p "Which drive(s) to mount?" |
        while read -r chosen ; do
            if output=$(udisksctl mount -b "${chosen%% *}") ; then
                notify-send -t 2000 " USB mounter" "$output"
            else
                notify-send -u critical " USB mounter" "Error mounting $chosen"
            fi
        done
}

usbunmount() {
    echo "$drives_to_unmount" | $dmenu_command -p "Which drive(s) to unmount?" |
        while read -r chosen ; do
            if output=$(udisksctl unmount -b "${chosen%% *}") ; then
                notify-send -t 2000 " USB mounter" "${output%.}"
            else
                notify-send -u critical " USB mounter" "Error unmounting $chosen"
            fi
        done
}

asktype() {
    M=$(echo "$drives_to_mount" | awk -v ORS='' '{if (!x) {x=1; print $0} else {print ", "$0}}')
    U=$(echo "$drives_to_unmount" | awk -v ORS='' '{if (!x) {x=1; print $0} else {print ", "$0}}')
    case $(echo "Mount: $M\nUnmount: $U" | dmenu -i -matching fuzzy -no-custom -p "What do you want me to do?") in
        Mount*)
            if [ "$(echo "$drives_to_mount" | wc -l)" = 1 ] ; then
                if output=$(udisksctl mount -b "${drives_to_mount%% *}") ; then
                    notify-send -t 2000 " USB mounter" "$output"
                else
                    notify-send -u critical " USB mounter" "Error mounting $drives_to_mount"
                fi
            else
                usbmount
            fi
            ;;
        Unmount*)
            if [ "$(echo "$drives_to_unmount" | wc -l)" = 1 ] ; then
                if output=$(udisksctl unmount -b "${drives_to_unmount%% *}") ; then
                    notify-send -t 2000 " USB mounter" "${output%.}"
                else
                    notify-send -u critical " USB mounter" "Error unmounting $drives_to_unmount"
                fi
            else
                usbunmount
            fi
            ;;
    esac
}

if [ -n "$drives_to_mount" ] ; then
    if [ -z "$drives_to_unmount" ] ; then
        usbmount
    else
        asktype
    fi
else
    if [ -n "$drives_to_unmount" ] ; then
        usbunmount
    else
        notify-send -t 2000 " USB mounter" "No USB drives to mount or unmount"
    fi
fi
