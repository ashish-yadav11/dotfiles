#
# ~/.bashrc
#

# return if not running interactively
[[ "$-" != *i* ]] && return

HISTIGNORE="$HISTIGNORE:n:p:s:s *:t:u:y"

# aliases
alias c=compile
alias diffab="~/.scripts/diffab.sh | less -R"
alias fu="sudo ~/.scripts/hotspot.sh fix-unmanaged"
alias hlp="exec hotloop"
alias kynm="~/.scripts/xevcn.sh"
alias mse="ms && exit; echo -n '\a'"
alias ytmlog='nvim -c "normal G" ~/.cache/ytmsclu-daemon.log'

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
neomutt() {
    /usr/bin/neomutt "$@"
    pidof -sq /usr/bin/neomutt || rm -rf /tmp/neomutt/
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
