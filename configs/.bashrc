#
# ~/.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

# change cursor to block before entering external programs
PS0='\e[2 q'

# prompt
PS1='\[\033[38;5;167m\][\[\033[38;5;11m\]\u\[\033[38;5;10m\]@\[\033[38;5;12m\]\h \[\033[38;5;139m\]\W\[\033[38;5;167m\]]\[\033[0m\]$ '

# disable ^S ^Q
stty -ixon

# store bash history immediately
PROMPT_COMMAND="history -a"

# vi keybindings
set -o vi

# autocd
shopt -s autocd

# fzf keybindings
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

fzf_select_bookmark() {
    local selected
    selected=$(sed 's/#.*//g; /^\s*$/d' <"$HOME/.bookmarks" | fzf | cut -f1 -d'@')
    READLINE_LINE=$selected
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m emacs-standard -x '"\eb": "fzf_select_bookmark"'
bind -m vi-command -x '"\eb": "fzf_select_bookmark"'
bind -m vi-insert -x '"\eb": "fzf_select_bookmark"'

# termite tabbing functionality
source /etc/profile.d/vte.sh

# custom aliases
alias cp="cp -i"
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias diffc="diff --color=always"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias lessc="less -R"
alias ls="ls --color=auto"
alias newsboat="newsboat -q"
alias python="cgexec -g memory,cpuset:python /usr/bin/python"
alias rm="rm -i"
alias startx="startx &>$HOME/.local/share/xorg/startx.$XDG_VTNR.log"
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

# environment varaibles
export HISTCONTROL=ignoredups
export HISTSIZE=10000

# custom functions

b() {
    if [[ $1 -ge 1 && $1 -le 255 ]] ; then
        echo "$1" >/sys/class/backlight/radeon_bl0/brightness
    else
        echo "bash: b: Invalid argument"
    fi
}

mkcd() {
    mkdir "$1" && cd "$1"
}

neomutt() {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt >/dev/null 2>&1 || rm -rf /tmp/neomutt/
}

nt() {
    {
        sleep "$(echo "$1*60" | bc)"
        shift 1
        notify-send -t 0 "$*"
    } & disown
}

spull() {
    dir=$(pwd)

    cd /media/storage/.temporary/suckless-sites
    echo -e "\e[1;32msuckless sites\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/dwm
    echo -e "\e[1;32mdwm\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/st
    echo -e "\e[1;32mst\e[0m"
    git pull
    echo

    cd /media/storage/.temporary/suckless-software/scroll
    echo -e "\e[1;32mscroll\e[0m"
    git pull

    cd "$dir"
}

todo() {
    local todo_file=$HOME/Documents/.todo

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

ytm() {
    if (( $# )) ; then
        mpsyt "set -t show_video 0, set -t search_music 1, ,,, /$*"
    else
        mpsyt "set -t show_video 0, set -t search_music 1, ,,"
    fi
}

ytv() {
    if (( $# )) ; then
        mpsyt "set -t show_video 1, set -t search_music 0, ,,, /$*"
    else
        mpsyt "set -t show_video 1, set -t search_music 0, ,,"
    fi
}
