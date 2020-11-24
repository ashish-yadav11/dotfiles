#!/bin/dash
truncate() {
    sed 's/^[[:space:][:punct:]]*//; s/[[:space:][:punct:]]*$//' | tr '[:upper:]' '[:lower:]'
}

case $1 in
    sel)
        word=$(xclip -seletion primary -out | truncate)
        if [ -z "$word" ] ; then
            notify-send -t 2000 Dictionary "Nothing in primary selection"
            exit
        fi
        ;;
    *)
        word=$(yad --title=Dictionary --image=dictionary --no-buttons --entry \
                   --text=Dictionary --entry-label="Look up:" | truncate)
        [ -z "$word" ] && exit
        ;;
esac

dict "$word" >/tmp/dictionary.last.temp 2>&1
case $? in
    0)
        logfile=/home/ashish/Documents/.dictionary.log
        mv /tmp/dictionary.last.temp /tmp/dictionary.last
        sed -e "1i\\$word" -e "/^$word$/d" "$logfile" |
            head -10000 >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp "$logfile"
        termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last"
        ;;
    21)
        mv /tmp/dictionary.last.temp /tmp/dictionary.last
        termite --name=floating_Termite -t Dictionary -e "less /tmp/dictionary.last"
        ;;
    *)
        rm -f /tmp/dictionary.last.temp
        notify-send -t 2000 Dictionary "No definitions found for the word"
        ;;
esac
