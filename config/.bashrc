#
# ~/.bashrc
#

# return if not running interactively
[[ "$-" != *i* ]] && return

HISTIGNORE="$HISTIGNORE:d:m:n:p:s:s *:t:u:y"

# aliases
alias c=compile
alias diffab="~/.scripts/diffab.sh | less -R"
alias fu="sudo ~/.scripts/hotspot.sh fix-unmanaged"
alias hlp="exec hotloop"
alias kynm="~/.scripts/xevcn.sh"
alias dlke="dlk && exit; echo -n '\a'"
alias ulke="ulk && exit; echo -n '\a'"
alias mse="ms && exit; echo -n '\a'"
alias ytmlog='nvim -c "normal G" ~/.cache/ytmsclu-daemon.log'
alias zcurle="zcurl && exit; echo -n '\a'"

alias n="nvim ~/Documents/.notes"
alias t="nvim ~/Documents/.todo"
alias u="nvim ~/Documents/.urls"

alias h='nvim -c "normal G" ~/.bash_history'
alias p='nvim -c "normal G" ~/.python_history'
alias y='nvim -c "normal G" ~/.cache/ytmsclu-daemon.log'

__fzf_select_bookmark() {
    local selected
    selected="$(
        grep -Ev '^(#|\s*$)' ~/.bookmarks |
            fzf --height 40% -d' #' -n2.. -q "$READLINE_LINE"
    )" || return 1
    READLINE_LINE="${selected%% #*}"
    READLINE_POINT="${#READLINE_LINE}"
}
bind -m vi-insert -x '"\eb": __fzf_select_bookmark'

# functions
d() {
    cd ~/Documents/.doubts
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
    local output
    output="$(__lk_helper "$@")" || { printf "%s" "$output"; return ;}
    echo "$output"
    ~/.scripts/ytmsclu-addjob.sh "$output" like
}

ulk() {
    local arg output
    arg="unlike"
    [ "$1" = "-r" ] && { arg="remove"; shift ;}
    output="$(__lk_helper "$@")" || { printf "%s" "$output"; return ;}
    echo "$output"
    ~/.scripts/ytmsclu-addjob.sh "$output" "$arg"
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

trash-list() {
    case "$1" in
        -n) /usr/bin/trash-list | sort -k3,3 ;;
         *) /usr/bin/trash-list | sort ;;
    esac
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
        read -r -p "Are you sure you want to zcurl $url [y/N]: " confirm
        [[ "$confirm" != y && "$confirm" != Y ]] && return 2
    fi
    filepath="/var/tmp/${url##*/}"
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return 1 ;}
    echo "$(date '+%y%m%d-%H%M%S') $url" >>~/.zcurl_history
    setsid -f sh -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}
