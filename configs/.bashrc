#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '

# prompt
PS1='\[\033[38;5;167m\][\[\033[38;5;11m\]\u\[\033[38;5;10m\]@\[\033[38;5;12m\]\h \[\033[38;5;139m\]\W\[\033[38;5;167m\]]\[\033[0m\]$ '

# disable ^S ^Q
stty -ixon

# store bash history immediately
PROMPT_COMMAND="history -a"

# vi keybindings
set -o vi

# autocd
shopt -s autocd

# fzf keybindings
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

fzf_select_bookmark() {
    local selected
    selected=$(sed 's/#.*//g; /^\s*$/d' <"$HOME/.bookmarks" | fzf | cut -f1 -d'@')
    READLINE_LINE=$selected
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m emacs-standard -x '"\eb": "fzf_select_bookmark"'
bind -m vi-command -x '"\eb": "fzf_select_bookmark"'
bind -m vi-insert -x '"\eb": "fzf_select_bookmark"'

# termite tabbing functionality
source /etc/profile.d/vte.sh

# custom aliases
alias cp="cp -i"
alias diffab="/home/ashish/.scripts/diffab.sh | less -R"
alias diffc="diff --color=always"
alias fu="sudo /home/ashish/.scripts/hotspot.sh fix-unmanaged"
alias kynm="/home/ashish/.scripts/xevcn.sh"
alias lessc="less -R"
alias python="cgexec -g memory,cpuset:python /usr/bin/python"
alias rm="rm -i"
alias startx="startx &>$HOME/.local/share/xorg/startx.$XDG_VTNR.log"
alias tree="tree -C"
alias vi=nvim
alias vim=nvim

# environment varaibles
export HISTCONTROL=ignoredups
export HISTSIZE=10000

# custom functions

# change brightness
b() {
    if (( $1 >= 1 && $1 <= 255 )) ; then
        echo "$1" >/sys/class/backlight/radeon_bl0/brightness
    else
        echo "Invalid argument"
    fi
}


# browse bookmarks
bb() {
  local open ruby output
  open=xdg-open
  ruby=$(command -v ruby)
  output=$($ruby << EORUBY
# encoding: utf-8

require 'json'
FILE = '$HOME/.config/BraveSoftware/Brave-Browser/Default/Bookmarks'
#FILE = '$HOME/.config/google-chrome/Default/Bookmarks'
CJK  = /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/

def build parent, json
  name = [parent, json['name']].compact.join('/')  
  if json['type'] == 'folder'
    json['children'].map { |child| build name, child }
  else
    { name: name, url: json['url'] }
  end
end

def just str, width
  str.ljust(width - str.scan(CJK).length)
end

def trim str, width
  len = 0
  str.each_char.each_with_index do |char, idx|
    len += char =~ CJK ? 2 : 1
    return str[0, idx] if len > width
  end
  str
end

width = $(tput cols).to_i / 2
json  = JSON.load File.read File.expand_path FILE
items = json['roots']
        .values_at(*%w(bookmark_bar synced other))
        .compact
        .map { |e| build nil, e }
        .flatten

items.each do |item|
  name = trim item[:name], width
  puts [just(name, width),
        item[:url]].join("\t\x1b[36m") + "\x1b[m"
end
EORUBY
)

  echo -e "$output" |
  fzf --ansi --multi  --tiebreak=begin |
  awk 'BEGIN { FS = "\t" } { print $2 }' |
  xargs "$open" &>/dev/null

}


# browse history
bh() {
  local cols sep browser_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  browser_history=$HOME/.config/BraveSoftware/Brave-Browser/Default/History
#  browser_history=$HOME/.config/google-chrome/Default/History
  open=xdg-open
  cp -f "$browser_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs "$open" &>/dev/null
}


cdls() {
	local dir=${*:(-1)}
        (( $# )) || local dir=$HOME
	if [[ -d $dir ]]; then
		cd "$dir" >/dev/null || return
                if (( $# > 1 )) ; then
                    ls "${@:1:$#-1}"
                else
                    ls
                fi
	else
		echo "bash: cdls: $dir: No such directory"
	fi
}


mkcd() {
    mkdir "$1"
    cd "$1"
}


nt() {
    ( sleep "$(echo "scale=2; $1*60" | bc)"
    shift 1
    notify-send -t 0 "$*" ) & disown
}


spull() {
    echo -e "\e[1;32msuckless sites\e[0m"
    git --git-dir=/media/storage/.temporary/suckless-sites/.git \
        --work-tree=/media/storage/.temporary/suckless-sites pull
    echo ""

    echo -e "\e[1;32mdwm\e[0m"
    git --git-dir=/media/storage/.temporary/suckless-software/dwm/.git \
        --work-tree=/media/storage/.temporary/suckless-software/dwm pull
    echo ""

    echo -e "\e[1;32mst\e[0m"
    git --git-dir=/media/storage/.temporary/suckless-software/st/.git \
        --work-tree=/media/storage/.temporary/suckless-software/st pull
    echo ""

    echo -e "\e[1;32mscroll\e[0m"
    git --git-dir=/media/storage/.temporary/suckless-software/scroll/.git \
        --work-tree=/media/storage/.temporary/suckless-software/scroll pull
}


todo() {
    [[ ! -f $HOME/Documents/.todo ]] && touch "$HOME/Documents/.todo"

    if (( ! $# )) ; then
        nl -b a "$HOME/Documents/.todo"
    elif [[ $1 == -e ]] ; then
        nvim "$HOME/Documents/.todo"
    elif [[ $1 == -c ]] ; then
        echo -n "" >"$HOME/Documents/.todo"
    elif [[ $1 == -r ]] ; then
        if (( $2 > 0 )) ; then
            sed -i "$2d" "$HOME/Documents/.todo"
        else
            nl -b a "$HOME/Documents/.todo"
            eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\} ; echo
            read -rp "Type index of the task to remove: " index
            (( index > 0 )) && sed -i "${index}d" "$HOME/Documents/.todo"
        fi
    else
        printf "%s\n" "$*" >>"$HOME/Documents/.todo"
    fi
}
