#
# ~/.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

HISTIGNORE=$HISTIGNORE:l:m:n:s:t

# aliases
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias md='youtube-dl --output "%(title)s (%(id)s).%(ext)s" --extract-audio --audio-format best --audio-quality 0'
alias startx='startx &>"$HOME/.local/share/xorg/startx.$XDG_VTNR.log"'

alias l="nvim ~/Documents/.lag"
alias n="nvim ~/Documents/.notes"
alias t="nvim ~/Documents/.todo"

__fzf_select_bookmark() {
    local selected
    selected=$(
        grep -Ev '^(#|\s*$)' ~/.bookmarks |
            fzf --height 40% -d' #' -n2.. -q "$READLINE_LINE"
    ) || return
    READLINE_LINE=${selected%% #*}
    READLINE_POINT=${#READLINE_LINE}
}

bind -m emacs-standard -x '"\eb": __fzf_select_bookmark'
bind -m vi-command -x '"\eb": __fzf_select_bookmark'
bind -m vi-insert -x '"\eb": __fzf_select_bookmark'

# functions
m() {
    if [[ -x ./make.sh ]] ; then
        ./make.sh "$@"
    else
        echo "No make.sh in this directory!"
    fi
}

neomutt() {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt &>/dev/null || rm -rf /tmp/neomutt/
}

s() {
    if [[ -x ./sync.sh ]] ; then
        ./sync.sh "$@"
    else
        echo "No sync.sh in this directory!"
    fi
}

share() {
    local link
    if [[ ! -f $1 ]] ; then
        printf "file %q doesn't exist!" "$1"
        return
    fi
    if link=$(curl -F"file=@$1" "https://0x0.st") ; then
        echo -n "$link" | xsel -ib
        echo "$link"
    fi
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
    [[ $url != http*.pdf ]] && { echo "Invalid URL!"; return ;}
    curl -sfLIo /dev/null "$url" || { echo "Invalid URL or network error!"; return ;}
    filepath=/tmp/${url##*/}
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return ;}
    setsid -f dash -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}
