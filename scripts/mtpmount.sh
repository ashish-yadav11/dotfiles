#!/bin/bash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -multi-select -no-custom"

# clean stale simple-mtpfs temporary directories
for dir in /tmp/simple-mtpfs-* ; do
    output=$(ls -A "$dir" 2>/dev/null) && [ -z "$output" ] && rmdir "$dir"
done

# plugged-in mtp devices
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f = 1; next}
        !f {next}
        $0 == "" {f = 0; next}
        $1 == "E: DEVNAME" {b = $2 "|"; n = $2; sub(/^\/dev\/bus\/usb\//, "", n); sub(/\//, "", n); next}
        $1 == "E: ID_VENDOR" {gsub(/[ _]/, "-", $2); v = $2; b = b $2 " "; next}
        $1 == "E: ID_MODEL" {m = $2; gsub(/[ _]/, "-", m); if (v != $2) {gsub(/_/, " ", $2); if (v != $2) {b = b $2 " "}}; next}
        $1 == "E: ID_SERIAL_SHORT" {print m "-" $2 "-" n "|" b "(" $2 ")"; next}
    '
)

# mtp devices not mounted on the system
declare -a devices0=( "${devices[@]}" )
# mtp devices mounted on the system
declare -a devices1=()
# mount points
declare -a mtpoints=()

i=0
while read -r mtpoint ; do
    base=${mtpoint##*/}
    for j in "${!devices0[@]}" ; do
        if [[ ${devices0[j]} == "$base|"* ]] ; then
            devices0=( "${devices0[@]:0:j}" "${devices0[@]:j+1}" )
            devices1[i]=${devices[j]}
            mtpoints[i]=$mtpoint
            (( i++ ))
            continue 2
        fi
    done
    # cleanup orphaned mount points
    fusermount -u "$mtpoint" && rmdir "$mtpoint"
done < <(awk '$1=="simple-mtpfs" {print $2}' /etc/mtab)

mount() {
    device=${devices0[$1]}
    name=${device##*|}; name=${name% (*}
    devname=${device#*|}; devname=${devname%|*}
    mtpoint=/run/user/$UID/mtp/${device%%|*}
    mkdir -p "$mtpoint"
    if output=$(simple-mtpfs "$devname" "$mtpoint" 2>&1) ; then
        notify-send -t 2000 " MTP mounter" "$name mounted successfully"
    elif [[ $output == *"make sure the screen is unlocked." ]] ; then
        notify-send -u critical -t 10000 " MTP mounter" "Error mounting $name\nMake sure the device is unlocked and file transfer (MTP) option is selected for the USB connection"
        rmdir "$mtpoint"
    else
        notify-send -u critical " MTP mounter" "Error mounting $name"
        rmdir "$mtpoint"
    fi
}

unmount() {
    device=${devices1[$1]}
    name=${device##*|}; name=${name% (*}
    mtpoint=${mtpoints[$1]}
    if fusermount -u "$mtpoint" 2>/dev/null ; then
        notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
        rmdir "$mtpoint"
    else
        notify-send -u critical " MTP mounter" "Error unmounting $name"
    fi
}

askmount() {
    printf "%s\n" "${devices0[@]##*|}" | $menu -format i -p "Which device(s) to mount?" |
        while read -r i ; do
            mount "$i"
        done
}

askunmount() {
    printf "%s\n" "${devices1[@]##*|}" | $menu -format i -p "Which device(s) to unmount?" |
        while read -r i ; do
            unmount "$i"
        done
}

asktype() {
    M=$(printf "%s\n" "${devices0[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')
    U=$(printf "%s\n" "${devices1[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')

    echo -e "Mount: ${M%?}\nUnmount: ${U%?}" | $menu -p "What to do?" |
        while read -r chosen ; do
            case $chosen in
                M*)
                    case $M in
                        *s) mount 0 ;;
                        *m) askmount ;;
                    esac
                    ;;
                U*)
                    case $U in
                        *s) unmount 0 ;;
                        *m) askunmount ;;
                    esac
                    ;;
            esac
        done
}

if (( ${#devices0[@]} )) ; then
    if (( ${#devices1[@]} )) ; then
        asktype
    else
        askmount
    fi
else
    if (( ${#devices1[@]} )) ; then
        askunmount
    else
        notify-send -t 2000 " MTP mounter" "No MTP device to mount or unmount"
    fi
fi
