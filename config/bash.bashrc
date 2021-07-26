#
# /etc/bash.bashrc
#

# return if not running interactively
[[ "$-" != *i* ]] && return

[[ -n "$DISPLAY" ]] && shopt -s checkwinsize

[[ -n "$NEWTERM_PWD" ]] && { cd "$NEWTERM_PWD"; unset NEWTERM_PWD ;}

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

HISTIGNORE=h:pb:pz

# locale
LC_ALL=C

# save history immediately
if [[ -n "$PROMPT_COMMAND" ]] ; then
    PROMPT_COMMAND="$PROMPT_COMMAND"'
history -a'
else
    PROMPT_COMMAND='history -a'
fi

# title, st newterm and termite tabbing
case "$TERM" in
    st*)
        PROMPT_COMMAND="$PROMPT_COMMAND"'
printf "\e]7;%s\e\\" "$PWD"
printf "\e]0;%s@%s:%s\e\\" "$USER" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/\~}"'
        ;;
    *termite*)
        PROMPT_COMMAND="$PROMPT_COMMAND"'
printf "\e]0;%s@%s:%s\e\\" "$USER" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/\~}"'
        source /etc/profile.d/vte.sh
        ;;
    alacritty*)
        PROMPT_COMMAND="$PROMPT_COMMAND"'
printf "\e]0;%s@%s:%s\e\\" "$USER" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/\~}"'
        ;;
esac

# aliases
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

alias diffc="diff --color=always"
alias info="info --vi-keys"
alias lessc="less -R"
alias ls="ls --group-directories-first --color=auto"
alias sudo="sudo "
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

alias h='nvim -c "normal G" ~/.bash_history'
alias pb='bash --rcfile <(echo '\''[[ -f ~/.bashrc ]] && source ~/.bashrc; unset HISTFILE; PS1="\[\e[0;34m\]I\[\e[0m\]$PS1"'\'')'
alias pz="INCOGNITO=1 zsh"

# fzf keybindings
bind -m emacs-standard '"\C-s": transpose-chars'
bind -m vi-command '"\C-s": transpose-chars'
bind -m vi-insert '"\C-s": transpose-chars'

source /usr/share/fzf/key-bindings.bash

# functions
mkcd() {
    mkdir "$1" && cd "$1"
}

# autocompletion
source /usr/share/bash-completion/bash_completion
