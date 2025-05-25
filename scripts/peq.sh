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

case "$1" in
    enable)
        pw-metadata -n filters "$id" "filter.smart.disabled" false Spa:String:JSON
        ;;
    disable)
        pw-metadata -n filters "$id" "filter.smart.disabled" true Spa:String:JSON
        ;;
    *)
        if pw-metadata -n filters "$id" "filter.smart.disabled" |
                grep "key:'filter.smart.disabled' value:'true'" ; then
            pw-metadata -n filters "$id" "filter.smart.disabled" false Spa:String:JSON
        else
            pw-metadata -n filters "$id" "filter.smart.disabled" true Spa:String:JSON
        fi
        ;;
esac
