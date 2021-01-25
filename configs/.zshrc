## OPTIONS (man zshoptions)

setopt AUTO_CD
setopt GLOB_DOTS
setopt HIST_IGNORE_DUPS
setopt INC_APPEND_HISTORY
setopt CORRECT_ALL
unsetopt FLOW_CONTROL
setopt SH_WORD_SPLIT


## PARAMETERS (man zshparam)

HISTFILE=~/.zsh_history
HISTSIZE=10000
KEYTIMEOUT=1
PROMPT_EOL_MARK=''
PS1='%167F[%11F%n%10F@%12F%M%139F %1~%167F]%f%k$ '
READNULLCMD=less
SAVEHIST=10000
zle_highlight=('region:bg=19' 'special:none' 'suffix:bold' 'isearch:underline' 'paste:none')


## MISCELLANEOUS (man zshmisc)

# terminal title
case $TERM in
    *termite*|*st*|*alacritty*|*rxvt*|*xterm*)
        function chpwd {
            print -Pn "\e]0;%n@%M:%~\a"
        }
        chpwd
        ;;
esac

# restore block cursor before running external commands
function preexec {
    echo -ne "\e[2 q"
}


## ZLE (man zshzle)

# vi keybindings
bindkey -v

# fix backspace and change cursor shape according to active mode
function zle-line-init zle-keymap-select {
    case $KEYMAP in
        vicmd)
            echo -ne "\e[2 q"
            ;;
        viins|main)
            if [[ $ZLE_STATE == *overwrite* ]] ; then
                UNDO_REPLACE_NO=$UNDO_CHANGE_NO
                echo -ne "\e[4 q"
            else
                echo -ne "\e[6 q"
            fi
            ;;
        *)
            echo -ne "\e[6 q"
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

bindkey -a "J" history-search-forward
bindkey -a "K" history-search-backward

bindkey -v "\C-n" down-history
bindkey -v "\C-p" up-history

# insert key
bindkey -v "\e[2~" overwrite-mode
bindkey -a "\e[2~" vi-insert

# delete key
bindkey -v "\e[3~" delete-char
bindkey -a "\e[3~" delete-char

# home key
bindkey -v "\e[H" beginning-of-line
bindkey -a "\e[H" beginning-of-line

# pgup key
bindkey -v "\e[5~" history-search-backward
bindkey -a "\e[5~" history-search-backward

# pgdn key
bindkey -v "\e[6~" history-search-forward
bindkey -a "\e[6~" history-search-forward

# end key
bindkey -v "\e[F" end-of-line # end key
bindkey -a "\e[F" end-of-line # end key

function fzf-select-bookmark {
    local selected
    selected=$(grep -Ev '^(#|\s*$)' "$HOME/.bookmarks" | fzf --height 40% -d' #' -n2..)
    selected=${selected%% #*}
    LBUFFER=$selected
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

autoload -Uz run-help
unalias run-help
alias help=run-help


## CUSTOM

# aliases
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias newsboat="newsboat -q"
alias startx="startx &>'$HOME/.local/share/xorg/startx.$XDG_VTNR.log'"

#functions
function neomutt {
    /usr/bin/neomutt "$@"
    pidof -s /usr/bin/neomutt &>/dev/null || rm -rf /tmp/neomutt/
}
function spull {
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
function trash-list {
    case $1 in
        -n) /usr/bin/trash-list | sort -k3,3 ;;
         *) /usr/bin/trash-list | sort ;;
    esac
}
function zcurl {
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


## PLUGINS

# fzf-tab
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:toggle-sort'
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# termite tabbing
source /etc/profile.d/vte.sh

# fzf key bindings
source /usr/share/fzf/key-bindings.zsh
