#!/bin/dash
cid="\033[32m"
ctm="\033[33m"
cqu="\033[34m"
cur="\033[36m"
cdf="\033[0m"

# merge redundant descriptions for running jobs
at -l | LC_ALL=C sort -k6,6 -k3,3M -k4,4 -k5,5 | awk '{
        if (r) {
            r = 0
            printf "%s,%s %s %02d %s %04d,~%c,%s\n",$1,$2,$3,$4,$5,$6,$7,$8
        } else if ($7 == "=") {
            r = 1
        } else {
            printf "%s,%s %s %02d %s %04d, %c,%s\n",$1,$2,$3,$4,$5,$6,$7,$8
        }
    }' | while read -r job ; do
        id=${job%%,*}; job=${job#*,}
        tm=${job%%,*}; job=${job#*,}
        qu=${job%,*}
        ur=${job#*,}
        echo "${cid}${id}\t${ctm}${tm} ${cqu}${qu} ${cur}${ur}${cdf}"
        # only print commands which were supplied by the user
        case $qu in
            ~*)
                at -c "$id" | awk '{
                        if (p) {
                            if ($0 == "") {
                                s = s"\n"
                            } else if ($0 ~ /^Subject: Output from your job/ || $0 ~ /^To: /) {
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
                at -c "$id" | awk '{
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
    done
