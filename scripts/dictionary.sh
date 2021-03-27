#!/bin/dash
truncate() {
    sed 's/^[[:space:][:punct:]]*//; s/[[:space:][:punct:]]*$//' |
        tr '[:upper:]' '[:lower:]'
}

case $1 in
    selection)
        word=$(xsel -op | truncate)
        if [ -z "$word" ] ; then
            notify-send -t 2000 Dictionary "Nothing in primary selection!"
            exit
        fi
        ;;
    *)
        word=$(yad --title=Dictionary --image=dictionary --no-buttons --entry \
                   --text=Dictionary --entry-label="Look up:" | truncate)
        [ -z "$word" ] && exit
        ;;
esac

dict "$word" >/tmp/dictionary.last.temp
case $? in
    0)
        mv /tmp/dictionary.last.temp /tmp/dictionary.last
        termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last"
        ;;
    21)
        termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last.temp"
        rm -f /tmp/dictionary.last.temp
        ;;
    *)
        rm -f /tmp/dictionary.last.temp
        notify-send -t 2000 Dictionary "No definitions found for the word"
        ;;
esac
