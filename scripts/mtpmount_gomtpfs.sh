#!/bin/bash
menu() {
    rofi -theme-str 'window {anchor: north; location: north; width: 100%;}
                     listview {lines: 1; columns: 9;}' \
         -dmenu -i -matching fuzzy -multi-select -no-custom "$@"
}

# plugged-in mtp devices
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f=1; next}
        !f {next}
        $1=="E: DEVNAME" {D=substr($2,14,3) substr($2,18); next}
        $1=="E: ID_VENDOR" {v=toupper(substr($2,1,1)) tolower(substr($2,2)); V=toupper(v); next}
        $1=="E: ID_MODEL" {M=toupper($2); next}
        $1=="E: ID_SERIAL_SHORT" {S=$2; next}
        $0=="" {i=index(M,V);
            if (i==1) {M=substr(M,length(V)+2); sub(/[ _].*/,"",M); N=v" "M; m=v"-"M}
            else if (i==0) {sub(/[ _].*/,"",M); N=v" "M; m=v"-"M}
            else {N=M; m=M};
            print m"-"S"-"D"|"N" ("S")"; f=0; next}
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
    base="${mtpoint##*/}"
    for j in "${!devices0[@]}" ; do
        if [[ "${devices0[j]}" == "$base|"* ]] ; then
            devices0=( "${devices0[@]:0:j}" "${devices0[@]:j+1}" )
            devices1[i]="${devices[j]}"
            mtpoints[i]="$mtpoint"
            (( i++ ))
            continue 2
        fi
    done
    # cleanup orphaned mount points
    fusermount -u "$mtpoint" && rm -rf "$mtpoint" "$mtpoint.log"
done < <(awk '$1=="rawBridge" && $2~/^\/run\/user\/[0-9]*\/mtp\// {print $2}' /etc/mtab)

mount() {
    device="${devices0[$1]}"
    name="${device##*|}"; name="${name% (*}"
    serial="${device##* (}"; serial="${serial%)}"
    mtpoint="$XDG_RUNTIME_DIR/mtp/${device%|*}"
    mkdir -p "$mtpoint"
    setsid -f go-mtpfs -usb-timeout 10000 -dev "$serial" "$mtpoint" &>"$mtpoint.log"
    sleep 0.1
    timeout="$(( SECONDS + 2 ))"
    while (( SECONDS < timeout )) ; do
        IFS='' read -r line <"$mtpoint.log" && [[ -n "$line" ]] && break
        sleep 0.1
    done
    if [[ "$line" == *"FUSE mounted" ]] ; then
        shopt -s nullglob dotglob
        files=( "$mtpoint"/* )
        shopt -u nullglob dotglob
        if (( ${#files[*]} )) ; then
            notify-send -t 2000 " MTP mounter" "$name mounted successfully"
        else
            notify-send -u critical -t 10000 " MTP mounter" "Error mounting $name\nMake sure the device is unlocked and file transfer (MTP) option is selected for the USB connection"
            fusermount -u "$mtpoint" && rm -rf "$mtpoint" "$mtpoint.log"
        fi
    else
        notify-send -u critical -t 0 " MTP mounter" "Error mounting $name"
    fi
}

unmount() {
    device="${devices1[$1]}"
    name="${device##*|}"; name="${name% (*}"
    mtpoint="${mtpoints[$1]}"
    if fusermount -u "$mtpoint" 2>/dev/null ; then
        notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
        rm -rf "$mtpoint" "$mtpoint.log"
    else
        notify-send -u critical -t 4000 " MTP mounter" "Error unmounting $name\nResource might be busy"
    fi
}

askmount() {
    printf "%s\n" "${devices0[@]##*|}" | menu -format i -p Mount: |
        while IFS='' read -r i ; do
            mount "$i"
        done
}

askunmount() {
    printf "%s\n" "${devices1[@]##*|}" | menu -format i -p Unmount: |
        while IFS='' read -r i ; do
            unmount "$i"
        done
}

asktype() {
    M="$(printf "%s\n" "${devices0[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')"
    U="$(printf "%s\n" "${devices1[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')"

    echo -e "Mount: ${M%?}\nUnmount: ${U%?}" | menu -p "What to do?" |
        while IFS='' read -r chosen ; do
            case "$chosen" in
                M*)
                    case "$M" in
                        *s) mount 0 ;;
                        *m) askmount ;;
                    esac
                    ;;
                U*)
                    case "$U" in
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
