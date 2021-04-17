#!/bin/bash
menu="rofi -dmenu -location 1 -width 100 -lines 1 -columns 9 -i -matching fuzzy -multi-select -no-custom"

# plugged-in mtp devices
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $0=="" {f=0; next}
        $1=="E: DEVNAME" {d=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_VENDOR" {gsub(/_/," ",$2); v=$2; next}
        $1=="E: ID_MODEL" {m=$2; gsub(/[ _]/,"-",m); gsub(/_/," ",$2); n=v==$2?v:v" "$2; next}
        $1=="E: ID_SERIAL_SHORT" {print m"-"$2"-"d"|"n" ("$2")"; next}
    '
)

# mtp devices not mounted on the system
declare -a devices0=( "${devices[@]}" )
# mtp devices mounted on the system
declare -a devices1=()
# mount points
declare -a mtpoints=()

i=0
while IFS='' read -r mtpoint ; do
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
    if fusermount -u "$mtpoint" ; then
        rmdir "$mtpoint"
        rm -f "$mtpoint.log"
    fi
done < <(awk '$1=="rawBridge" && $2~/^\/run\/user\/[0-9]*\/mtp\// {print $2}' /etc/mtab)

mount() {
    device=${devices0[$1]}
    name=${device##*|}; name=${name% (*}
    serial=${device#* (}; serial=${serial%)}
    mtpoint=/run/user/$UID/mtp/${device%%|*}
    mkdir -p "$mtpoint"
    setsid -f go-mtpfs -dev "$serial" "$mtpoint" &>"$mtpoint.log"
    sleep 0.1
    while IFS='' read -r line <"$mtpoint.log" ; do
        [[ -n $line ]] && break
        sleep 0.1
    done
    if [[ $line == *"FUSE mounted" ]] ; then
        shopt -s nullglob dotglob
        files=( "$mtpoint"/* )
        shopt -u nullglob dotglob
        if (( ${#files[*]} )) ; then
            notify-send -t 2000 " MTP mounter" "$name mounted successfully"
        else
            notify-send -u critical -t 10000 " MTP mounter" "Error mounting $name\nMake sure the device is unlocked and file transfer (MTP) option is selected for the USB connection"
            if fusermount -u "$mtpoint" ; then
                rmdir "$mtpoint"
                rm -f "$mtpoint.log"
            fi
        fi
    else
        notify-send -u critical " MTP mounter" "Error mounting $name"
        rmdir "$mtpoint"
        rm -f "$mtpoint.log"
    fi
}

unmount() {
    device=${devices1[$1]}
    name=${device##*|}; name=${name% (*}
    mtpoint=${mtpoints[$1]}
    if fusermount -u "$mtpoint" 2>/dev/null ; then
        notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
        rmdir "$mtpoint"
        rm -f "$mtpoint.log"
    else
        notify-send -u critical " MTP mounter" "Error unmounting $name\nResource might be busy"
    fi
}

askmount() {
    printf "%s\n" "${devices0[@]##*|}" | $menu -format i -p "Which device(s) to mount?" |
        while IFS='' read -r i ; do
            mount "$i"
        done
}

askunmount() {
    printf "%s\n" "${devices1[@]##*|}" | $menu -format i -p "Which device(s) to unmount?" |
        while IFS='' read -r i ; do
            unmount "$i"
        done
}

asktype() {
    M=$(printf "%s\n" "${devices0[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')
    U=$(printf "%s\n" "${devices1[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')

    echo -e "Mount: ${M%?}\nUnmount: ${U%?}" | $menu -p "What to do?" |
        while IFS='' read -r chosen ; do
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
