#
# ~/.bashrc
#

# return if not running interactively
[[ "$-" != *i* ]] && return

HISTIGNORE="$HISTIGNORE:l:m:n:s:s *:t"

# aliases
alias c=compile
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias dme="dm && exit"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm=/home/ashish/.scripts/xevcn.sh
alias mse="ms && exit"
alias zcurle="zcurl && exit"

alias l="nvim ~/Documents/.lag"
alias n="nvim ~/Documents/.notes"
alias t="nvim ~/Documents/.todo"

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
dm() {
    local url
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

m() {
    if [[ -x ./make.sh ]] ; then
        ./make.sh "$@"
    else
        echo "No make.sh in this directory!"
    fi
}

ms() {
    local src dst
    src=/media/storage/Music/
    dst=( "$XDG_RUNTIME_DIR/mtp/RMX1831-9PLF7LKZKNFYLR5H-"*"/Internal shared storage/Music" )
    if [[ -d "${dst[0]}" ]] ; then
        rsync -avu --delete "$src" "${dst[0]}"
    else
        echo "Destination device not mounted!"
        return 1
    fi
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

zcurl() {
    local url
    case "$#" in
        0) url="$(xsel -ob)" || { echo "Nothing in clipboard!"; return 1 ;} ;;
        1) url="$1" ;;
        *) echo "Usage: zcurl [url]" ;;
    esac
    curl -sfLIo /dev/null "$url" || { echo "Invalid URL or network error!"; return 1 ;}
    if [[ "$url" != http*.pdf ]] ; then
        read -r -p "Are you sure you want to zcurl $url [y/N]: " confirm
        [[ "$confirm" != y && "$confirm" != Y ]] && return 0
    fi
    filepath="/var/tmp/${url##*/}"
    curl -Lo "$filepath" "$url" || { rm -f "$filepath"; echo "Network error!"; return 1 ;}
    setsid -f sh -c 'zathura "$0"; rm -f "$0"' "$filepath" 2>/dev/null
}
