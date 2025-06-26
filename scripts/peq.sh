#!/bin/dash
device="d07dac"
case "$1" in
    -h) echo "peq [-di/-dd] [enable/disable/toggle]"; exit ;;
    -di) device="inbuilt"; shift ;;
    -dd) device="d07dac"; shift ;;
esac

id="$(pw-cli list-objects Node | awk '
        $1 == "id" && $2 ~ /^[0-9]+,/ && $3 == "type" {
            id=substr($2, 1, length($2)-1)
        }
        $1 == "node.name" && $2 == "=" && $3 == "\"'"$device"'-smartpeq_input\"" {
            found = 1
            exit
        }
        END {
            if (found) {print id}
        }'
)"
if [ -z "$id" ] ; then
    echo "Error: couldn't find the sink $device-smartpeq_input!"
    exit 2
fi

isdisabledpeq() {
    case "$(pw-metadata -n filters "$id" "filter.smart.disabled" |
                grep -m1 "key:'filter.smart.disabled'")" in
            *"' value:'true' type:'Spa:String:JSON'")
            return 0
            ;;
        *"' value:'false' type:'Spa:String:JSON'")
            return 1
            ;;
        *)
            if pw-cli info "$id" |
                grep -qm1 'filter.smart.disabled = "true"' ; then
            return 0
        else
            return 1
            fi
            ;;
    esac
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
            echo -n "PEQ is disabled for <$device>. Enable it? [Y/n]: "
            read -r input && case "$input" in n|N) exit ;; esac
            enablepeq
        else
            echo -n "PEQ is enabled for <$device>. Disable it? [y/N]: "
            read -r input && case "$input" in y|Y) disablepeq ;; esac
        fi
        ;;
esac
