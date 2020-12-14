#
# /etc/bash.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

[[ -n $DISPLAY ]] && shopt -s checkwinsize

# autocd
shopt -s autocd

# disable ^S ^Q
stty -ixon

# change cursor to block before entering external programs
PS0="\e[2 q"

blue="\[\e[38;5;12m\]"
green="\[\e[38;5;10m\]"
red="\[\e[38;5;167m\]"
violet="\[\e[38;5;139m\]"
white="\[\e[0m\]"
yellow="\[\e[38;5;11m\]"

# prompt
PS1="${red}[${yellow}\u${green}@${blue}\h ${violet}\W${red}]${white}$ "

# history (export to prevent history truncation when running sh)
export HISTCONTROL=ignoredups
export HISTSIZE=10000

# fix sorting in completion
LC_ALL=C

# termite tabbing
source /etc/profile.d/vte.sh

case $TERM in
    *termite*|*st*|*alacritty*)
        __prompt_command() {
            printf "\e]0;%s@%s:%s\a" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
            history -a
        }
        ;;
    *)
        __prompt_command() {
            history -a
        }
    ;;
esac

# set title and save history immediately
PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}__prompt_command

# aliases
alias cp="cp -i"
alias diffc="diff --color=always"
alias lessc="less -R"
alias ls="ls --color=auto"
alias python="cgexec -g memory,cpuset:python /usr/bin/python"
alias rm="rm -i"
alias sudo="sudo "
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

# fzf keybindings
bind -m emacs-standard '"\C-s": transpose-chars'
bind -m vi-command '"\C-s": transpose-chars'
bind -m vi-insert '"\C-s": transpose-chars'

source /usr/share/fzf/key-bindings.bash

# functions
btns() {
    if [[ $1 -ge 1 && $1 -le 255 ]] ; then
        echo "$1" >/sys/class/backlight/radeon_bl0/brightness
    else
        echo "bash: b: Invalid argument"
    fi
}

mkcd() {
    mkdir "$1" && cd "$1"
}

# autocompletion
source /usr/share/bash-completion/bash_completion
source /usr/share/fzf/completion.bash
