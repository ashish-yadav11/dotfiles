#!/bin/bash
if [[ $1 == ranger ]] ; then
    command="ranger --cmd='set show_hidden=false'"
else
    command=$(printf %q "$1")
fi
for arg in "${@:2}" ; do
    command="$command $(printf %q "$arg")"
done
exec termite -e "$command"
