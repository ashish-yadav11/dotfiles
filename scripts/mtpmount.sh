#!/bin/bash
dmenu="dmenu -i -matching fuzzy -multi-select -no-custom -format i"

# plugged-in mtp devices
mapfile -t devices < <(
    udevadm info -n /dev/bus/usb/*/* | awk -F= '
        /^S: libmtp/ {f = 1; next}
        !f {next}
        $0 == "" {f = 0; next}
        $1 == "E: BUSNUM" {b = $2 ","; next}
        $1 == "E: DEVNUM" {b = b $2 "|"; next}
        $1 == "E: ID_VENDOR" {v = $2; b = b $2 " "; next}
        $1 == "E: ID_MODEL" {m = $2; if (v != $2) {b = b $2 " "}; next}
        $1 == "E: ID_SERIAL_SHORT" {print m "-" $2 "|" b "(" $2 ")"; next}
    '
)

mapfile -t devices1 < <(awk '$1=="jmtpfs" {print $2}' /etc/mtab)

if (( ${#devices1[@]} )) ; then
    # mtp devices not mounted on the system
    mapfile -t devices0 < <(printf "%s\n" "${devices[@]}" | grep -Fvf <(printf "%s|\n" "${devices1[@]##*/}"))
    # mtp devices mounted on the system
    mapfile -t devices1 < <(printf "%s\n" "${devices[@]}" | grep -Ff <(printf "%s|\n" "${devices1[@]##*/}"))
else
    devices0=( "${devices[@]}" )
    devices1=()
fi

mtpmount() {
    printf "%s\n" "${devices0[@]##*|}" | $dmenu -p "Which device(s) to mount?" |
        while read -r i ; do
            device=${devices0[$i]}
            name=${device%%|*}
            busdev=${device#*|}; busdev=${busdev%|*}
            mpoint=/run/user/$UID/mtp/$name
            mkdir -p "$mpoint"
            if jmtpfs -device="$busdev" "$mpoint" >/dev/null 2>&1 ; then
                notify-send -t 2000 " MTP mounter" "$name mounted successfully"
            else
                notify-send -u critical " MTP mounter" "Error mounting $name"
            fi
        done
}

mtpunmount() {
    printf "%s\n" "${devices1[@]##*|}" | $dmenu -p "Which device(s) to unmount?" |
        while read -r i ; do
            device=${devices1[$i]}
            name=${device%%|*}
            mpoint=/run/user/$UID/mtp/$name
            if fusermount -u "$mpoint" 2>/dev/null ; then
                notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
            else
                notify-send -u critical " MTP mounter" "Error unmounting $name"
            fi
            rmdir "$mpoint"
        done
}

asktype() {
    M=$(echo "${devices0[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')
    U=$(echo "${devices1[@]##*|}" | awk -v ORS='' '{print (NR==1) ? $0 : ", "$0}; END {print (NR==1) ? "s" : "m"}')

    echo -e "Mount: ${M%?}\nUnmount: ${U%?}" | $dmenu -p "What to do?" |
        while read -r chosen ; do
            case $chosen in
            M*)
                case $M in
                *s)
                    device=${devices0[0]}
                    name=${device%%|*}
                    busdev=${device#*|}; busdev=${busdev%|*}
                    mpoint=/run/user/$UID/mtp/$name
                    mkdir -p "$mpoint"
                    if jmtpfs -device="$busdev" "$mpoint" >/dev/null 2>&1 ; then
                        notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
                    else
                        notify-send -u critical " MTP mounter" "Error unmounting $name"
                    fi
                    ;;
                *m)
                    mtpmount
                    ;;
                esac
                ;;
            U*)
                case $U in
                *s)
                    device=${devices1[0]}
                    name=${device%%|*}
                    mpoint=/run/user/$UID/mtp/$name
                    if fusermount -u "$mpoint" 2>/dev/null ; then
                        notify-send -t 2000 " MTP mounter" "$name unmounted successfully"
                    else
                        notify-send -u critical " MTP mounter" "Error unmounting $name"
                    fi
                    rmdir "$mpoint"
                    ;;
                *m)
                    mtpunmount
                    ;;
                esac
                ;;
            esac
        done
}

if (( ${#devices0[@]} )) ; then
    if (( ${devices1[@]} )) ; then
        asktype
    else
        mtpmount
    fi
else
    if (( ${#devices1[@]} )) ; then
        mtpunmount
    else
        notify-send -t 2000 " MTP mounter" "No MTP device to mount or unmount"
    fi
fi
