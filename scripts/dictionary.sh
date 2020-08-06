#!/bin/dash
case "$1" in
    sel)
        word=$(xclip -seletion primary -out | tr '[:upper:]' '[:lower:]' | xargs)
        if [ -z "$word" ] ; then
            notify-send -t 2000 "Dictionary" "Nothing in primary selection"
            exit
        fi
        ;;
    last)
        if [ -f /tmp/dictionary.last ] ; then
            termite --name=dictionary_Termite -t Dictionary -e "less /tmp/dictionary.last"
        else
            notify-send -t 2000 "Dictionary" "Last word not available"
        fi
        exit
        ;;
    *)
        word=$(yad --title=Dictionary --image=dictionary --no-buttons --entry --text=Dictionary \
                   --entry-label="Look up:" | tr '[:upper:]' '[:lower:]' | xargs)
        [ -z "$word" ] && exit
        ;;
esac

dict "$word" >/tmp/dictionary.last.temp 2>&1
case "$?" in
    0)
        mv /tmp/dictionary.last.temp /tmp/dictionary.last
        termite --name=dictionary_Termite -t Dictionary -e "less /tmp/dictionary.last"
        echo "$word" >>/home/ashish/Documents/.dictionary.log
        awk '!visited[$0]++' /home/ashish/Documents/.dictionary.log | tail -50 >/tmp/dictionary.log.temp
        mv /tmp/dictionary.log.temp /home/ashish/Documents/.dictionary.log
        ;;
    21)
        mv /tmp/dictionary.last.temp /tmp/dictionary.last
        termite --name=dictionary_Termite -t Dictionary -e "less /tmp/dictionary.last"
        ;;
    *)
        rm -f /tmp/dictionary.last.temp
        notify-send -t 2000 "Dictionary" "No definitions found for the word"
        ;;
esac
