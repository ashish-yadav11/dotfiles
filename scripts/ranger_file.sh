#!/bin/dash
RANGER_LEVEL=0 setsid -f termite -e "ranger --selectfile='$1'"
