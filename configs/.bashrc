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
    selected=$(grep -Ev '^(#|\s*$)' "$HOME/.bookmarks" | fzf --height 40% -d' #' -n2..)
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
    echo -e "\e[1;32msuckless sites\e[0m"
    git -C /media/storage/.temporary/suckless-sites pull

    echo -e "\n\e[1;32mdwm\e[0m"
    git -C /media/storage/.temporary/suckless-software/dwm pull

    echo -e "\n\e[1;32mst\e[0m"
    git -C /media/storage/.temporary/suckless-software/st pull

    echo -e "\n\e[1;32mscroll\e[0m"
    git -C /media/storage/.temporary/suckless-software/scroll pull
}

trash-list() {
    case $1 in
        -n) /usr/bin/trash-list | sort -k3,3 ;;
         *) /usr/bin/trash-list | sort ;;
    esac
}

zcurl() {
    case $# in
        0) url=$(xsel -ob) || { echo "Nothing in clipboard!"; return ;} ;;
        1) url=$1 ;;
        *) echo "Usage: zcurl [url]" ;;
    esac
    if [[ $url != http*.pdf ]] || ! curl -sfLIo /dev/null "$url" ; then
        echo "Invalid URL!"
        return
    fi
    curl -L "$url" | zathura - 2>/dev/null
}
