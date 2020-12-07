#
# /etc/bash.bashrc
#

# return if not running interactively
[[ $- != *i* ]] && return

[[ -n $DISPLAY ]] && shopt -s checkwinsize

# change cursor to block before entering external programs
PS0='\e[2 q'

blue='\[\033[38;5;12m\]'
green='\[\033[38;5;10m\]'
red='\[\033[38;5;167m\]'
violet='\[\033[38;5;139m\]'
white='\[\033[0m\]'
yellow='\[\033[38;5;11m\]'

# prompt
PS1="${red}[${yellow}\u${green}@${blue}\h ${violet}\W${red}]${white}$ "

# autocd
shopt -s autocd

# disable ^S ^Q
stty -ixon

# fzf keybindings
bind -m emacs-standard '"\C-s": transpose-chars'
bind -m vi-command '"\C-s": transpose-chars'
bind -m vi-insert '"\C-s": transpose-chars'

source /home/ashish/.scripts/fzf.bash

__prompt_command() {
    case $TERM in
        xterm-termite)
            # window title
            printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
            # termite tabbing functionality
            printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "$(/usr/lib/vte-urlencode-cwd)"
            ;;
        xterm*|alacritty*|rxvt*|Eterm|aterm|kterm|gnome*)
            # window title
            printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
            ;;
    esac
    # store bash history immediately
    history -a
}

# shell variables
HISTCONTROL=ignoredups
HISTSIZE=10000
PROMPT_COMMAND=__prompt_command

# custom aliases
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

# custom functions
atqc() {
    local c_id="\e[32m"
    local c_tm="\e[33m"
    local c_qu="\e[34m"
    local c_ur="\e[36m"

    atq | sort -r -k6,6 -k3,3M -k4,4 -k5,5 |
        while read -r job ; do
            ur=${job##* }; job=${job% *}
            qu=${job##* }; job=${job% *}
            tm=${job#*$'\t'}
            id=${job%%$'\t'*}
            echo -e "${c_id}${id}\t${c_tm}${tm} ${c_qu}${qu} ${c_ur}${ur}\e[0m"
            # only print the commands supplied by the user
            at -c "$id" | awk 'p; $0=="}" {p=1}'
        done
}

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
