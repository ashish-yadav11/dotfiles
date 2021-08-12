#!/bin/dash
# requires https://metacpan.org/pod/Regexp::Common::URI
perl -M'Regexp::Common=URI' -pe 's/($RE{URI})/\e[1;31m$1\e[0m/g' | less -R
