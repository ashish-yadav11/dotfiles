#!/bin/dash
ip=192.168.12.10

getaudiooption() {
    case "$(echo "Without Audio\nWith Audio" |
                dmenu -p " ScrCpy" -i -matching fuzzy -no-custom)" in
        "With Audio") scrcpy="scrcpy" ;;
        "Without Audio") scrcpy="scrcpy --no-audio" ;;
        *) exit ;;
    esac
}
warnnotif() {
    notify-send -t 2000 " ScrCpy" "Device not connected"
}
grepwarn() {
    grep -qFm1 'WARN: Device disconnected'
}

if ping -c1 -W1 "$ip" >/dev/null ; then
    getaudiooption
    $scrcpy --tcpip="$ip" --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
    if [ "$?" = 1 ] ; then
        $scrcpy --tcpip --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
        [ "$?" = 1 ] && warnnotif
    fi
elif [ "$(adb devices | wc -l)" -gt 2 ] ; then
    getaudiooption
    $scrcpy -d --max-size=1920 --shortcut-mod=lctrl,rctrl "$@"
    [ "$?" = 1 ] && warnnotif
else
    warnnotif
fi
