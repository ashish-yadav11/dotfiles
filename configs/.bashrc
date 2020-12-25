#
# ~/.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

# aliases
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias newsboat="newsboat -q"
alias startx="startx &>'$HOME/.local/share/xorg/startx.$XDG_VTNR.log'"

__fzf_select_bookmark() {
    local selected
    selected=$(grep -Ev '(^#)|(^\s*$)' "$HOME/.bookmarks" | fzf -d' #' -n2..)
    selected=${selected%% #*}
    READLINE_LINE=$selected
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m emacs-standard -x '"\eb": __fzf_select_bookmark'
bind -m vi-command -x '"\eb": __fzf_select_bookmark'
bind -m vi-insert -x '"\eb": __fzf_select_bookmark'

# functions
neomutt() {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt &>/dev/null || rm -rf /tmp/neomutt/
}

spull() {
    local dir
    dir=$(pwd)

    cd /media/storage/.temporary/suckless-sites || return
    echo -e "\e[1;32msuckless sites\e[0m"
    git pull

    cd /media/storage/.temporary/suckless-software/dwm || return
    echo -e "\n\e[1;32mdwm\e[0m"
    git pull

    cd /media/storage/.temporary/suckless-software/st || return
    echo -e "\n\e[1;32mst\e[0m"
    git pull

    cd /media/storage/.temporary/suckless-software/scroll || return
    echo -e "\n\e[1;32mscroll\e[0m"
    git pull

    cd "$dir"
}

trash-list() {
    case $1 in
        -n)
            /usr/bin/trash-list | sort -k3,3 ;;
        *)
            /usr/bin/trash-list | sort ;;
    esac
}
