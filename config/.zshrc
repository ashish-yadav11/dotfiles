### GLOBAL

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
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt CORRECT
unsetopt FLOW_CONTROL
setopt INTERACTIVE_COMMENTS
setopt SH_WORD_SPLIT


## PARAMETERS (man zshparam)

HISTORY_IGNORE='(d|h|l|m|n|p|pb|pz|s|s *|t|u|y)'
HISTSIZE=20000
KEYTIMEOUT=1
LC_ALL=C
PROMPT_EOL_MARK=''
READNULLCMD=less
SAVEHIST=20000
zle_highlight=(region:bg=#504945 special:none suffix:bold isearch:underline paste:none)


## MISCELLANEOUS (man zshmisc)

# restore default cursor before running external commands and before exit
function preexec zshexit {
    echo -ne "$defcursor"
}

# don't add commands starting with space to the history file,
# but keep them in internal history
function zshaddhistory {
    case "$1" in " "*) return 2 ;;
        *) return 0 ;;
    esac
}


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

bindkey -a 'J' history-search-forward
bindkey -a 'K' history-search-backward

bindkey -v '\C-n' down-history
bindkey -v '\C-p' up-history

# emacs keys in vi insert mode
bindkey -v '\C-a' beginning-of-line
bindkey -v '\C-e' end-of-line
bindkey -v '\C-b' backward-char
bindkey -v '\C-f' forward-char
bindkey -v '\C-k' kill-line
bindkey -v '\C-u' kill-whole-line
bindkey -v '\C-s' transpose-chars
bindkey -v '\C-d' delete-char-or-list

# special keys (https://wiki.archlinux.org/title/zsh)

# create a zkbd compatible hash
# (to add other keys to this hash, see: man 5 terminfo)
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

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# setup key accordingly
 [[ -n "${key[Home]}"      ]] &&   bindkeyboth   "${key[Home]}"       beginning-of-line
 [[ -n "${key[End]}"       ]] &&   bindkeyboth   "${key[End]}"        end-of-line
 [[ -n "${key[Insert]}"    ]] && { bindkey -v -- "${key[Insert]}"     overwrite-mode
                                   bindkey -a -- "${key[Insert]}"     vi-insert ;}
 [[ -n "${key[Backspace]}" ]] && { bindkey -v -- "${key[Backspace]}"  viins-backward-delete-char
                                   bindkey -a -- "${key[Backspace]}"  backward-char ;}
 [[ -n "${key[Delete]}"    ]] &&   bindkeyboth   "${key[Delete]}"     delete-char
 [[ -n "${key[Up]}"        ]] &&   bindkeyboth   "${key[Up]}"         up-line-or-beginning-search
 [[ -n "${key[Down]}"      ]] &&   bindkeyboth   "${key[Down]}"       down-line-or-beginning-search
 [[ -n "${key[Left]}"      ]] &&   bindkeyboth   "${key[Left]}"       backward-char
 [[ -n "${key[Right]}"     ]] &&   bindkeyboth   "${key[Right]}"      forward-char
 [[ -n "${key[PageUp]}"    ]] &&   bindkeyboth   "${key[PageUp]}"     history-beginning-search-backward
 [[ -n "${key[PageDown]}"  ]] &&   bindkeyboth   "${key[PageDown]}"   history-beginning-search-backward
#[[ -n "${key[Shift-Tab]}" ]] &&   bindkeyboth   "${key[Shift-Tab]}"  reverse-menu-complete

# finally, make sure the terminal is in application mode, when zle is active;
# only then are the values from $terminfo valid
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
bindkeyboth '\er' exec-ranger-0
bindkeyboth '\eR' exec-ranger-1

function fzf-select-bookmark {
    local selected lbuffer
    echo -ne "$inscursor"
    lbuffer="$LBUFFER"
    LBUFFER=""
    zle -R
    if selected="$(grep -Ev '^(#|\s*$)' ~/.bookmarks |
                      fzf --height 40% -d' #' -n2.. -q "$lbuffer")" ; then
        LBUFFER="${selected%% #*}"
    else
        LBUFFER="$lbuffer"
    fi
    zle-line-init
    zle reset-prompt
}
zle -N fzf-select-bookmark
bindkeyboth '\eb' fzf-select-bookmark


## COMPLETION (man zshcompsys)

autoload -Uz compinit
compinit -d ~/.cache/zcompdump


## CONTRIB (man zshcontrib)

autoload -Uz edit-command-line
zle -N edit-command-line
bindkeyboth '\C-o' edit-command-line

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
alias psp="pactl set-card-profile"
alias pgs="pactl get-default-sink"
alias pss="pactl set-default-sink"
alias sudo="sudo "
alias sysusrctl="systemctl --user"
alias termdown="date; termdown"
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

# scripts and commands
alias c=compile
alias diffab="~/.scripts/diffab.sh | less -R"
alias fu="sudo ~/.scripts/hotspot.sh fix-unmanaged"
alias hlp="exec hotloop"
alias kynm="~/.scripts/xevcn.sh"
alias mse="ms && exit; echo -n '\a'"
dlke() {
    dlk "$@" && exit
    echo -n '\a'
}
ulke() {
    ulk "$@" && exit
    echo -n '\a'
}
zcurle() {
    zcurl "$@" && exit
    echo -n '\a'
}

# files
alias n="nvim ~/Documents/.notes"
alias t="nvim ~/Documents/.todo"
alias u="nvim ~/Documents/.urls"

# history
alias h='nvim -c "normal G" ~/.zsh_history'
alias p='nvim -c "normal G" ~/.python_history'
alias y='nvim -c "normal G" ~/.cache/ytmsclu-daemon.log'
alias pb='bash --rcfile <(echo '\''[[ -f ~/.bashrc ]] && source ~/.bashrc; unset HISTFILE; PS1="\[\e[0;34m\]I\[\e[0m\]$PS1"'\'')'
alias pz="INCOGNITO=1 zsh"


d() {
    cd ~/Documents/.doubts
    nvim
}

l() {
    cd ~/Documents/.logs
    nvim
}

__lk_helper() {
    local url
    case "$#" in
        0) url="$(xsel -ob)" ;;
        1) url="$1" ;;
        *) echo "Invalid usage!"; return 2 ;;
    esac
    if ! echo "$url" | grep -qm1 \
            "^https://\(music\|www\)\.youtube\.com/watch?v=...........\(&\|$\)" ; then
        echo "Invalid url: \`$url'!"
        return 1
    fi
    url="${url%%&*}"
    echo -n "$url" | xsel -ib
    echo "$url"
}

dlk() {
    local output rtrn ans
    output="$(__lk_helper "$@")" ||
        { rtrn="$?"; printf "%s" "$output"; return "$rtrn" ;}
    echo "$output"
    title="$(ytb-title "$output")"
    echo "$title"
    read -r 'ans?Continue? [Y/n]: '
    [[ "$ans" == n || "$ans" == N ]] && return 2
    ~/.scripts/ytmsclu-addjob.sh "$output" like "$title"
}

ulk() {
    local output rtrn ans arg
    output="$(__lk_helper "$@")" ||
        { rtrn="$?"; printf "%s" "$output"; return "$rtrn" ;}
    echo "$output"
    title="$(ytb-title "$output")"
    echo "$title"
    arg="unlike"
    read -r 'ans?[U]nlike/[R]emove/[D]elete? [U/r/d]: '
    if [[ "$ans" == r || "$ans" == R ]] ; then
        arg="remove"
    elif [[ "$ans" == d || "$ans" == D ]] ; then
        arg="delete"
    fi
    read -r 'ans?Continue? [Y/n]: '
    [[ "$ans" == n || "$ans" == N ]] && return 2
    ~/.scripts/ytmsclu-addjob.sh "$output" "$arg" "$title"
}

m() {
    local curdir
    if [[ -x ./make.sh ]] ; then
        ./make.sh "$@"
        return
    fi
    if [[ -x ../make.sh ]] ; then
        curdir="$PWD"
        cd ..
        ./make.sh "$@"
        cd "$curdir"
        return
    fi
    echo "No make.sh in this or the parent directory!"
}

mkcd() {
    mkdir "$@" && cd "${@: -1}"
}

neomutt() {
    /usr/bin/neomutt "$@"
    pidof -sq /usr/bin/neomutt || rm -rf /tmp/neomutt/
}

pdftkd() {
    pdftk "$1" dump_data output "${2:-info}"
}

pdftku() {
    local dir base ext bak
    dir="$(dirname "$1")"
    base="$(basename "$1")"
    ext="${base##*.}"; base="${base%.*}"
    bak="${dir}/${base}_.${ext}"
    /usr/bin/mv -b "$1" "$bak"
    pdftk "$bak" update_info "${2:-info}" output "$1"
}

djvud() {
    djvused "$1" -e "print-outline" >"${2:-bmarks}"
}

djvuu() {
    local dir base ext bak
    dir="$(dirname "$1")"
    base="$(basename "$1")"
    ext="${base##*.}"; base="${base%.*}"
    bak="${dir}/${base}_.${ext}"
    /usr/bin/cp "$1" "$bak"
    djvused "$1" -e "set-outline ${2:-bmarks}; save"

}

share() {
    local file url
    file="$1"
    if [[ ! -f "$file" ]] ; then
        printf "file %q doesn't exist!" "$file"
        return 1
    fi
    file="\"$(echo "$file" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')\""
    if url="$(curl -F"file=@$file" "https://0x0.st")" ; then
        echo -n "$url" | xsel -ib
        echo "$url"
    fi
}

spull() {
    echo -e '\e[1;32msuckless sites\e[0m'
    git -C /media/storage/.temporary/suckless-sites pull

    echo -e '\n\e[1;32mdwm\e[0m'
    git -C /media/storage/.temporary/suckless-software/dwm pull

    echo -e '\n\e[1;32mst\e[0m'
    git -C /media/storage/.temporary/suckless-software/st pull

    echo -e '\n\e[1;32mscroll\e[0m'
    git -C /media/storage/.temporary/suckless-software/scroll pull
}

startx() {
    [[ -f "$XLOGFILE" ]] && { mv -f "$XLOGFILE" "$XLOGFILE.old" ;}
    /usr/bin/startx &>>"$XLOGFILE"
}

ytaudio() {
    yt-dlp --extract-audio --audio-format best --audio-quality 0 \
           --output "%(title)s (%(id)s).%(ext)s" "$@"
}

zcurl() {
    local url
    case "$#" in
        0) url="$(xsel -ob)" || { echo "Nothing in clipboard!"; return 1 ;} ;;
        1) url="$1" ;;
        *) echo "Usage: zcurl [url]" ;;
    esac
    echo "$url"
    curl -sfLIo /dev/null "$url" || { echo "Invalid URL or network error!"; return 1 ;}
    if ! [[ "$url" == http*.pdf || "$url" == http*/pdf/* ]] ; then
        read -r "?Are you sure you want to zcurl $url [y/N]: " confirm
        [[ "$confirm" != y && "$confirm" != Y ]] && return 2
    fi
    filepath="/var/tmp/${url##*/}"
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return 1 ;}
    echo "$(date '+%y%m%d-%H%M%S') $url" >>~/.zcurl_history
    setsid -f sh -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}

zpull() {
    echo -e '\e[1;32mfzf-tab\e[0m'
    git -C ~/.local/share/zsh/plugins/fzf-tab pull
}


## PLUGINS

# fzf-tab
zstyle ':fzf-tab:*' fzf-flags '-i'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:toggle-sort'
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# fzf key bindings
source /usr/share/fzf/key-bindings.zsh
bindkey -a '\C-u' redo

# system clipboard
[[ "$TERM" != linux ]] && source ~/.zshsrc

# syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
