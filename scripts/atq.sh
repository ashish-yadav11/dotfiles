#!/bin/dash
# merge redundant descriptions for running jobs
at -l | LC_ALL=C sort -k6,6 -k3,3M -k4,4 -k5,5 | awk '
    BEGIN {
        cid = "\033[32m"
        ctm = "\033[33m"
        cqu = "\033[34m"
        cur = "\033[36m"
        cdf = "\033[0m"
    }
    {
        if (r) {
            r = 0
            printf "%s%s\t%s%s %s %2d %s %4d %s~%c %s%s%s|%s\n",
                    cid,$1,ctm,$2,$3,$4,$5,$6,cqu,$7,cur,$8,cdf,$1
        } else if ($7 == "=") {
            r = 1
        } else {
            printf "%s%s\t%s%s %s %2d %s %4d %s%c %s%s%s|%s\n",
                    cid,$1,ctm,$2,$3,$4,$5,$6,cqu,$7,cur,$8,cdf,$1
        }
    }' | while read -r job ; do
        echo "${job%|*}"
        # only print commands which were supplied by the user
        case $job in
            *~*)
                at -c "${job##*|}" | awk '{
                        if (p) {
                            if ($0 == "") {
                                s = s"\n"
                            } else if ($0 ~ /^(To: |Subject: Output from your job)/) {
                                s = ""
                            } else {
                                print s$0
                                s = ""
                            }
                        } else if ($0 == "}") {
                            p = 1
                        }
                    }'
                ;;
            *)
                at -c "${job##*|}" | awk '{
                        if (p) {
                            if ($0 == "") {
                                s = s"\n"
                            } else {
                                print s$0
                                s = ""
                            }
                        } else if ($0 == "}") {
                            p = 1
                        }
                    }'
                ;;
        esac
        echo
    done
