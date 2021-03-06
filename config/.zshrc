## CONSOLE/TERMINAL SPECIFIC

if [[ $TERM == linux ]] ; then
    source ~/.zshcrc
else
    source ~/.zshtrc
fi


## OPTIONS (man zshoptions)

setopt AUTO_CD
setopt GLOB_DOTS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt CORRECT
unsetopt FLOW_CONTROL
setopt INTERACTIVE_COMMENTS
setopt SH_WORD_SPLIT


## PARAMETERS (man zshparam)

HISTORY_IGNORE='(h|l|m|n|pb|pz|s|t)'
HISTSIZE=12000
KEYTIMEOUT=1
LC_ALL=C
PROMPT_EOL_MARK=''
READNULLCMD=less
SAVEHIST=10000
zle_highlight=(region:bg=19 special:none suffix:bold isearch:underline paste:none)


## INCOGNITO MODE

if [[ -z $INCOGNITO ]] ; then
    HISTFILE=~/.zsh_history
else
    PS1="%F{blue}%f $PS1"
    unset INCOGNITO
fi


## ZLE (man zshzle)

# vi keybindings
bindkey -v

# fix backspace and change cursor shape according to active mode
function zle-line-init zle-keymap-select {
    case $KEYMAP in
        vicmd)
            echo -ne "$cmdcursor"
            ;;
        viins|main)
            if [[ $ZLE_STATE == *overwrite* ]] ; then
                UNDO_REPLACE_NO=$UNDO_CHANGE_NO
                echo -ne "$repcursor"
            else
                echo -ne "$inscursor"
            fi
            ;;
        *)
            echo -ne "$inscursor"
            ;;
    esac
}
function viins-backward-delete-char {
    if [[ $ZLE_STATE == *overwrite* ]] ; then
        if (( UNDO_CHANGE_NO > UNDO_REPLACE_NO )) ; then
            zle undo
            (( UNDO_REPLACE_NO++ ))
        else
            zle backward-char
        fi
    else
        zle backward-delete-char
    fi
}
zle -N zle-line-init
zle -N zle-keymap-select
zle -N viins-backward-delete-char
bindkey -v "\C-h" viins-backward-delete-char
bindkey -v "\C-?" viins-backward-delete-char

bindkey -v "\C-s" transpose-chars

bindkey -a "J" history-search-forward
bindkey -a "K" history-search-backward

bindkey -v "\C-n" down-history
bindkey -v "\C-p" up-history

function exec-ranger-0 {
    echo -ne "$defcursor"
    exec ranger --cmd="set show_hidden=false" <"$TTY"
}
function exec-ranger-1 {
    echo -ne "$defcursor"
    exec ranger <"$TTY"
}
zle -N exec-ranger-0
zle -N exec-ranger-1
bindkey -v "\er" exec-ranger-0
bindkey -v "\eR" exec-ranger-1

function fzf-select-bookmark {
    local selected lbuffer
    lbuffer=$LBUFFER
    LBUFFER=''
    zle -R
    if selected=$(grep -Ev '^(#|\s*$)' ~/.bookmarks |
                      fzf --height 40% -d' #' -n2.. -q "$lbuffer") ; then
        LBUFFER=${selected%% #*}
    else
        LBUFFER=$lbuffer
    fi
    zle reset-prompt
}
zle -N fzf-select-bookmark
bindkey -v "\eb" fzf-select-bookmark


## COMPLETION (man zshcompsys)

autoload -Uz compinit
compinit -d ~/.cache/zcompdump


## CONTRIB (man zshcontrib)

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -v "\C-e" edit-command-line
bindkey -a "\C-e" edit-command-line

unalias run-help
autoload -Uz run-help
alias help=run-help


## CUSTOM

# safeguards
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# re-definitions
alias diffc="diff --color=always"
alias info="info --vi-keys"
alias lessc="less -R"
alias ls="ls --group-directories-first --color=auto"
alias startx='startx &>"$HOME/.local/share/xorg/startx.$XDG_VTNR.log"'
alias sudo="sudo "
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

# scripts and commands
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias dme="dm && exit"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias mse="ms && exit"
alias zcurle="zcurl && exit"

# files
alias l="nvim ~/Documents/.lag"
alias n="nvim ~/Documents/.notes"
alias t="nvim ~/Documents/.todo"

# history
alias h='nvim -c "normal G" ~/.zsh_history'
alias pb='bash --rcfile <(echo '\''[[ -f ~/.bashrc ]] && source ~/.bashrc; unset HISTFILE; PS1="\[\e[0;34m\]\[\e[0m\] $PS1"'\'')'
alias pz="INCOGNITO=1 zsh"


function dm {
    case $# in
        0)
            url=$(xsel -ob) || { echo "Nothing in clipboard!"; return 1 ;}
            url=${url%%&*}
            echo -n "$url" | xsel -ib
            ;;
        1)
            url=$1
            ;;
        *)
            echo "Usage: dm [url]"
            ;;
    esac
    youtube-dl --extract-audio --audio-format best --audio-quality 0 --output "/media/storage/Music/%(title)s (%(id)s).%(ext)s" "$url"
}

function m {
    if [[ -x ./make.sh ]] ; then
        ./make.sh "$@"
    else
        echo "No make.sh in this directory!"
    fi
}

function mkcd {
    mkdir "$1" && cd "$1"
}

function ms {
    src=/media/storage/Music/
    unsetopt NOMATCH
    dst=( "$XDG_RUNTIME_DIR/mtp/RMX1831-9PLF7LKZKNFYLR5H-"*"/Internal shared storage/Music" )
    setopt NOMATCH
    if [[ -d "$dst[1]" ]] ; then
        rsync -avu --delete "$src" "$dst[1]"
    else
        echo "Destination device not mounted!"
        return 1
    fi
}

function neomutt {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt &>/dev/null || rm -rf /tmp/neomutt/
}

function s {
    if [[ -x ./sync.sh ]] ; then
        ./sync.sh "$@"
    else
        echo "No sync.sh in this directory!"
    fi
}

function share {
    local url
    if [[ ! -f $1 ]] ; then
        printf "file %q doesn't exist!" "$1"
        return 1
    fi
    if url=$(curl -F"file=@$1" "https://0x0.st") ; then
        echo -n "$url" | xsel -ib
        echo "$url"
    fi
}

function spull {
    echo -e "\e[1;32msuckless sites\e[0m"
    git -C /media/storage/.temporary/suckless-sites pull

    echo -e "\n\e[1;32mdwm\e[0m"
    git -C /media/storage/.temporary/suckless-software/dwm pull

    echo -e "\n\e[1;32mst\e[0m"
    git -C /media/storage/.temporary/suckless-software/st pull

    echo -e "\n\e[1;32mscroll\e[0m"
    git -C /media/storage/.temporary/suckless-software/scroll pull
}

function trash-list {
    case $1 in
        -n) /usr/bin/trash-list | sort -k3,3 ;;
         *) /usr/bin/trash-list | sort ;;
    esac
}

function zcurl {
    case $# in
        0) url=$(xsel -ob) || { echo "Nothing in clipboard!"; return 1 ;} ;;
        1) url=$1 ;;
        *) echo "Usage: zcurl [url]" ;;
    esac
    curl -sfLIo /dev/null "$url" || { echo "Invalid URL or network error!"; return 1 ;}
    if [[ $url != http*.pdf ]] ; then
        read -r "?Are you sure you want to zcurl $url [y/N]: " confirm
        [[ $confirm != y && $confirm != Y ]] && return 0
    fi
    filepath=/var/tmp/${url##*/}
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return 1 ;}
    setsid -f sh -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}

function zpull {
    echo -e "\e[1;32mfzf-tab\e[0m"
    git -C ~/.local/share/zsh/plugins/fzf-tab pull

    echo -e "\n\e[1;32mzsh-system-clipboard\e[0m"
    git -C ~/.local/share/zsh/plugins/zsh-system-clipboard pull
}


## PLUGINS

# fzf-tab
zstyle ':fzf-tab:*' fzf-flags '-i'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:toggle-sort'
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# fzf key bindings
source /usr/share/fzf/key-bindings.zsh

# system clipboard
source ~/.local/share/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh

# syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
