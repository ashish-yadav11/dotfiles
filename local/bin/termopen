#!/bin/bash
for arg in "$@" ; do
    command="$command $(printf %q "$arg")"
done
exec termite -e "${command# }"
