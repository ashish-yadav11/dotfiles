# return if not running interactively
[[ $- != *i* ]] && return

# ctrl-r - paste the selected command from history into the command line
__fzf_history() {
    local output
    output=$(
        builtin fc -lnr -2147483648 |
            last_hist=$(HISTTIMEFORMAT="" builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
                FZF_DEFAULT_OPTS="--height 40% $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort +m --read0" fzf --query "$READLINE_LINE") || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]] ; then
        echo "$READLINE_LINE"
    else
        READLINE_POINT=0x7fffffff
    fi
}

bind -m emacs-standard -x '"\C-r": __fzf_history'
bind -m vi-command -x '"\C-r": __fzf_history'
bind -m vi-insert -x '"\C-r": __fzf_history'

# ctrl-t - paste the selected file path into the command line
__fzf_file_widget() {
    local selected
    selected=$(
        fd -HL -tf -d4 | LC_COLLATE=C sort -f |
            FZF_DEFAULT_OPTS="--height 40% --reverse $FZF_DEFAULT_OPTS" fzf -m "$@" |
                while read -r item; do
                    printf "%q " "$item"
                done
        echo)
    READLINE_LINE=${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m emacs-standard -x '"\C-t": __fzf_file_widget'
bind -m vi-command -x '"\C-t": __fzf_file_widget'
bind -m vi-insert -x '"\C-t": __fzf_file_widget'

# alt-c - cd into the selected directory
__fzf_cd() {
    local dir
    dir=$(
        fd -HL -td -d4 | LC_COLLATE=C sort -f |
            FZF_DEFAULT_OPTS="--height 40% --reverse $FZF_DEFAULT_OPTS" fzf +m) && printf "cd %q" "$dir"
}

# required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\ec": "\C-z\ec\C-z"'
bind -m vi-insert '"\ec": "\C-z\ec\C-z"'
