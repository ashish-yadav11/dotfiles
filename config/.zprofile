## ENVIRONMENT VARIABLES (commented ones are set globally)

export BROWSER=brave
#export EDITOR=nvim
#export FZF_ALT_C_COMMAND="fd -HIL -td -d5"
#export FZF_CTRL_T_COMMAND="fd -HI -tf -d5"
#export FZF_DEFAULT_COMMAND="fd -HI -tf -d5"
#export FZF_DEFAULT_OPTS="--cycle --layout=reverse --no-unicode --bind='tab:down,btab:up,ctrl-d:delete-char,ctrl-g:first,ctrl-q:clear-selection,ctrl-v:select-all,ctrl-c:deselect-all,alt-enter:toggle,ctrl-o:toggle,ctrl-s:toggle,ctrl-t:toggle-all,ctrl-space:toggle-sort,ctrl-y:execute-silent(echo -n {} | xsel -ib)'"
export GOPATH=~/.local/lib/go
#export PAGER="less -R"
export PATH=~"/.local/bin:$PATH"
#export QT_QPA_PLATFORMTHEME=qt5ct
#export RADV_PERFTEST="video_decode,video_encode"
#export RANGER_LOAD_DEFAULT_RC=FALSE
export R_ENVIRON_USER=~/.Renviron
#export TERMINAL=st
#export VISUAL=nvim
export XLOGFILE=~"/.local/share/xorg/startx.$XDG_VTNR.log"

# fix for pacdiff to use nvim instead of vim
#export DIFFPROG="nvim -d"
# fix for escape keys in neomutt
export ESCDELAY=0


## MISCELLANEOUS

if [[ -z "$DISPLAY" && "$XDG_VTNR" -eq 1 ]] ; then
    [[ -f "$XLOGFILE" ]] && { mv -f "$XLOGFILE" "$XLOGFILE.old" ;}
    startx &>>"$XLOGFILE"
fi
