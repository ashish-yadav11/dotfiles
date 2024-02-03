#!/bin/dash

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

if [ "$(adb devices | wc -l)" -gt 2 ] ; then
    getaudiooption
    $scrcpy -d --shortcut-mod=lctrl,rctrl "$@"
    [ "$?" = 1 ] && warnnotif
else
    warnnotif
fi
