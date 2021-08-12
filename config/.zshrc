## CONSOLE/TERMINAL SPECIFIC

if [[ "$TERM" == linux ]] ; then
    source ~/.zshcrc
else
    source ~/.zshtrc
fi


## OPTIONS (man zshoptions)

setopt AUTO_CD
setopt GLOB_DOTS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt CORRECT
unsetopt FLOW_CONTROL
setopt INTERACTIVE_COMMENTS
setopt SH_WORD_SPLIT


## PARAMETERS (man zshparam)

HISTORY_IGNORE='(h|l|m|n|pb|pz|s|s *|t)'
HISTSIZE=20000
KEYTIMEOUT=1
LC_ALL=C
PROMPT_EOL_MARK=''
READNULLCMD=less
SAVEHIST=20000
zle_highlight=(region:bg=#504945 special:none suffix:bold isearch:underline paste:none)


## INCOGNITO MODE

if [[ -n "$INCOGNITO" ]] ; then
    PS1="%F{blue}I%f$PS1"
    unset INCOGNITO
else
    HISTFILE=~/.zsh_history
fi


## ZLE (man zshzle)

# vi keybindings
bindkey -v

# simultaneously bind key for both viins and vicmd modes
function bindkeyboth {
    bindkey -v -- "$1" "$2" #viins
    bindkey -a -- "$1" "$2" #vicmd
}

# fix backspace and change cursor shape according to active mode
function zle-line-init zle-keymap-select {
    case "$KEYMAP" in
        vicmd)
            echo -ne "$cmdcursor"
            ;;
        viins|main)
            if [[ "$ZLE_STATE" == *overwrite* ]] ; then
                UNDO_REPLACE_NO="$UNDO_CHANGE_NO"
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
    if [[ "$ZLE_STATE" == *overwrite* ]] ; then
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
bindkey -v '\C-h' viins-backward-delete-char
bindkey -v '\C-?' viins-backward-delete-char

function cleaner-clear-screen {
    echo -ne '\e[2K' # clear current prompt
    zle clear-screen
}
function reset-screen {
    echo -ne '\ec' # reset screen
    zle redisplay
}
zle -N cleaner-clear-screen
zle -N reset-screen
bindkeyboth '\C-l' cleaner-clear-screen
bindkeyboth '\el' reset-screen

bindkey -v '\C-s' transpose-chars

bindkey -a 'J' history-search-forward
bindkey -a 'K' history-search-backward

bindkey -v '\C-n' down-history
bindkey -v '\C-p' up-history

# special keys (https://wiki.archlinux.org/title/zsh)

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

 key[Home]="${terminfo[khome]}"
 key[End]="${terminfo[kend]}"
 key[Insert]="${terminfo[kich1]}"
 key[Backspace]="${terminfo[kbs]}"
 key[Delete]="${terminfo[kdch1]}"
 key[Up]="${terminfo[kcuu1]}"
 key[Down]="${terminfo[kcud1]}"
 key[Left]="${terminfo[kcub1]}"
 key[Right]="${terminfo[kcuf1]}"
 key[PageUp]="${terminfo[kpp]}"
 key[PageDown]="${terminfo[knp]}"
#key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
 [[ -n "${key[Home]}"      ]] &&   bindkeyboth   "${key[Home]}"       beginning-of-line
 [[ -n "${key[End]}"       ]] &&   bindkeyboth   "${key[End]}"        end-of-line
 [[ -n "${key[Insert]}"    ]] && { bindkey -v -- "${key[Insert]}"     overwrite-mode
                                   bindkey -a -- "${key[Insert]}"     vi-insert ;}
 [[ -n "${key[Backspace]}" ]] && { bindkey -v -- "${key[Backspace]}"  viins-backward-delete-char
                                   bindkey -a -- "${key[Backspace]}"  backward-char ;}
 [[ -n "${key[Delete]}"    ]] &&   bindkeyboth   "${key[Delete]}"     delete-char
 [[ -n "${key[Up]}"        ]] &&   bindkeyboth   "${key[Up]}"         up-line-or-history
 [[ -n "${key[Down]}"      ]] &&   bindkeyboth   "${key[Down]}"       down-line-or-history
 [[ -n "${key[Left]}"      ]] &&   bindkeyboth   "${key[Left]}"       backward-char
 [[ -n "${key[Right]}"     ]] &&   bindkeyboth   "${key[Right]}"      forward-char
 [[ -n "${key[PageUp]}"    ]] &&   bindkeyboth   "${key[PageUp]}"     history-search-backward
 [[ -n "${key[PageDown]}"  ]] &&   bindkeyboth   "${key[PageDown]}"   history-search-forward
#[[ -n "${key[Shift-Tab]}" ]] &&   bindkeyboth   "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

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
bindkey -v '\er' exec-ranger-0
bindkey -v '\eR' exec-ranger-1

function fzf-select-bookmark {
    local selected lbuffer
    lbuffer="$LBUFFER"
    LBUFFER=""
    zle -R
    if selected="$(grep -Ev '^(#|\s*$)' ~/.bookmarks |
                      fzf --height 40% -d' #' -n2.. -q "$lbuffer")" ; then
        LBUFFER="${selected%% #*}"
    else
        LBUFFER="$lbuffer"
    fi
    zle reset-prompt
}
zle -N fzf-select-bookmark
bindkey -v '\eb' fzf-select-bookmark


## COMPLETION (man zshcompsys)

autoload -Uz compinit
compinit -d ~/.cache/zcompdump


## CONTRIB (man zshcontrib)

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -v '\C-o' edit-command-line
bindkey -a '\C-o' edit-command-line

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
alias diffcc="diff -pu --color=always"
alias info="info --vi-keys"
alias lessc="less -R"
alias ls="ls --group-directories-first --color=auto"
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
alias pb='bash --rcfile <(echo '\''[[ -f ~/.bashrc ]] && source ~/.bashrc; unset HISTFILE; PS1="\[\e[0;34m\]I\[\e[0m\]$PS1"'\'')'
alias pz="INCOGNITO=1 zsh"


function dm {
    case "$#" in
        0)
            url="$(xsel -ob)" || { echo "Nothing in clipboard!"; return 1 ;}
            url="${url%%&*}"
            echo -n "$url" | xsel -ib
            ;;
        1)
            url="$1"
            ;;
        *)
            echo "Usage: dm [url]"
            ;;
    esac
    youtube-dl --extract-audio --audio-format best --audio-quality 0 \
               --output "/media/storage/Music/%(title)s (%(id)s).%(ext)s" "$url"
}

function m {
    if [[ -x ./make.sh ]] ; then
        ./make.sh "$@"
    else
        echo "No make.sh in this directory!"
    fi
}

function mkcd {
    mkdir "$@" && cd "${@: -1}"
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
    pidof -sq /usr/bin/neomutt || rm -rf /tmp/neomutt/
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
    if [[ ! -f "$1" ]] ; then
        printf "file %q doesn't exist!" "$1"
        return 1
    fi
    if url="$(curl -F"file=@$1" "https://0x0.st")" ; then
        echo -n "$url" | xsel -ib
        echo "$url"
    fi
}

function spull {
    echo -e '\e[1;32msuckless sites\e[0m'
    git -C /media/storage/.temporary/suckless-sites pull

    echo -e '\n\e[1;32mdwm\e[0m'
    git -C /media/storage/.temporary/suckless-software/dwm pull

    echo -e '\n\e[1;32mst\e[0m'
    git -C /media/storage/.temporary/suckless-software/st pull

    echo -e '\n\e[1;32mscroll\e[0m'
    git -C /media/storage/.temporary/suckless-software/scroll pull
}

function startx {
    [[ -f "$XLOGFILE" ]] && { mv -f "$XLOGFILE" "$XLOGFILE.old" ;}
    /usr/bin/startx &>>"$XLOGFILE"
}

function trash-list {
    case "$1" in
        -n) /usr/bin/trash-list | sort -k3,3 ;;
         *) /usr/bin/trash-list | sort ;;
    esac
}

function zcurl {
    case "$#" in
        0) url="$(xsel -ob)" || { echo "Nothing in clipboard!"; return 1 ;} ;;
        1) url="$1" ;;
        *) echo "Usage: zcurl [url]" ;;
    esac
    curl -sfLIo /dev/null "$url" || { echo "Invalid URL or network error!"; return 1 ;}
    if [[ "$url" != http*.pdf ]] ; then
        read -r "?Are you sure you want to zcurl $url [y/N]: " confirm
        [[ "$confirm" != y && "$confirm" != Y ]] && return 0
    fi
    filepath="/var/tmp/${url##*/}"
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return 1 ;}
    setsid -f sh -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}

function zpull {
    echo -e '\e[1;32mfzf-tab\e[0m'
    git -C ~/.local/share/zsh/plugins/fzf-tab pull

    echo -e '\n\e[1;32mzsh-system-clipboard\e[0m'
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
