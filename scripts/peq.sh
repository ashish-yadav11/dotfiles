#!/bin/dash
id="$(pw-cli list-objects Node | awk '
        $1 == "id" && $2 ~ /^[0-9]+,/ && $3 == "type" {
            id=substr($2, 1, length($2)-1)
        }
        $1 == "node.name" && $2 == "=" && $3 == "\"inbuilt-smartpeq_input\"" {
            found = 1
            exit
        }
        END {
            if (found) {print id}
        }'
)"
if [ -z "$id" ] ; then
    echo "Error: couldn't find the sink inbuilt-smartpeq_input!"
    exit 2
fi

isdisabledpeq() {
    pw-metadata -n filters "$id" "filter.smart.disabled" |
        grep "key:'filter.smart.disabled' value:'true'"
}
enablepeq() {
        pw-metadata -n filters "$id" "filter.smart.disabled" false Spa:String:JSON
}
disablepeq() {
        pw-metadata -n filters "$id" "filter.smart.disabled" true Spa:String:JSON
}

case "$1" in
    enable)
        enablepeq
        ;;
    disable)
        disablepeq
        ;;
    toggle)
        if isdisabledpeq ; then
            enablepeq
        else
            disablepeq
        fi
        ;;
    *)
        if isdisabledpeq ; then
            echo -n "PEQ is disabled. Enable it? [Y/n]: "
            read -r input && case "$input" in n|N) exit ;; esac
            enablepeq
        else
            echo -n "PEQ is enabled. Disable it? [y/N]: "
            read -r input && case "$input" in y|Y) disablepeq ;; esac
        fi
        ;;
esac
