#
# ~/.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

__fzf_select_bookmark() {
    local selected
    selected=$(grep -Ev '(^#)|(^\s*$)' "$HOME/.bookmarks" | fzf -d' #' -n2 | awk -F' #' '{print $1}')
    READLINE_LINE=$selected
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m emacs-standard -x '"\eb": __fzf_select_bookmark'
bind -m vi-command -x '"\eb": __fzf_select_bookmark'
bind -m vi-insert -x '"\eb": __fzf_select_bookmark'

# custom aliases
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias newsboat="newsboat -q"
alias startx="startx &>'$HOME/.local/share/xorg/startx.$XDG_VTNR.log'"

# custom functions
neomutt() {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt >/dev/null 2>&1 || rm -rf /tmp/neomutt/
}

nt() {
    {
        sleep "$(echo "$1*60" | bc)"
        notify-send -t 0 "${*:2}"
    } & disown
}

rd() {
    if [[ $1 -ge 1000 && $1 -le 6500 ]] ; then
        redshift -PO "$1" >/dev/null 2>&1
    else
        redshift -x >/dev/null 2>&1
    fi
}

spull() {
    local dir
    dir=$(pwd)

    cd /media/storage/.temporary/suckless-sites || return
    echo -e "\e[1;32msuckless sites\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/dwm || return
    echo -e "\e[1;32mdwm\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/st || return
    echo -e "\e[1;32mst\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/scroll || return
    echo -e "\e[1;32mscroll\e[0m"
    git pull

    cd "$dir"
}

todo() {
    local todo_file
    todo_file=$HOME/Documents/.todo

    if (( ! $# )) ; then
        if [[ -f "$todo_file" ]] ; then
            nl -b a "$todo_file"
        else
            touch "$todo_file"
        fi

    elif [[ $1 == -e ]] ; then
        [[ -f "$todo_file" ]] || touch "$todo_file"
        nvim "$todo_file"

    elif [[ $1 == -c ]] ; then
        : >"$todo_file"

    elif [[ $1 == -r ]] ; then
        if [[ ! -f "$todo_file" ]] ; then
            touch "$todo_file"
            exit
        fi
        if [[ $2 -gt 0 ]] ; then
            sed -i "$2d" "$todo_file"
        else
            nl -b a "$todo_file"
            eval printf "%.0s-" '{1..'"${COLUMNS:-$(tput cols)}"\}
            echo
            read -r -p "Type index of the task to remove: " index || echo
            [[ $index -gt 0 ]] && sed -i "${index}d" "$todo_file"
        fi

    else
        echo "$*" >>"$todo_file"

    fi
}
