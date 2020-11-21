#!/bin/dash

volume_step=1
volume_handler() {
    case $volume_step in
        1)
            case $event in
                "Event 'new' on client"*)
                    client_num=${event#*#}
                    volume_step=2
                    return 0
                    ;;
            esac
            ;;
        2)
            case $event in
                "Event 'change' on client #$client_num")
                    volume_step=3
                    return 0
                    ;;
            esac
            ;;
        3)
            case $event in
                "Event 'change' on sink"*)
                    volume_step=4
                    return 0
                    ;;
            esac
            ;;
        4)
            case $event in
                "Event 'remove' on client #$client_num")
                    sigdsblocks 2
                    volume_step=1
                    return 0
                    ;;
            esac
            ;;
    esac
    volume_step=1
    return 1
}

snd_card_num=1
update_headphone() {
    if grep -A3 'Headphone Playback Switch' /proc/asound/card$snd_card_num/codec#0 |
           grep -qF 'Amp-Out vals:  [0x00 0x00]' ; then
        sigdsblocks 2 1
    else
        sigdsblocks 2 0
    fi
}

headphone_step=1
headphone_handler() {
    case $headphone_step in
        1)
            case $event in
                "Event 'change' on card"*)
                    headphone_step=2
                    return 0
                    ;;
            esac
            ;;
        2)
            case $event in
                "Event 'change' on source"*)
                    update_headphone
                    headphone_step=1
                    return 0
                    ;;
            esac
            ;;
    esac
    headphone_step=1
    return 1
}

update_headphone
pactl subscribe |
    while read -r event ; do
        volume_handler || headphone_handler
    done
