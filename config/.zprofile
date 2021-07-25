## ENVIRONMENT VARIABLES (commented ones are set globally)

export BROWSER=brave
#export EDITOR=nvim
#export FZF_ALT_C_COMMAND="fd -HIL -td -d4 | LC_ALL=C sort -f"
#export FZF_CTRL_T_COMMAND="fd -HIL -tf -d4 | LC_ALL=C sort -f"
#export FZF_DEFAULT_COMMAND="fd -HIL -tf -d4 | LC_ALL=C sort -f"
#export FZF_DEFAULT_OPTS="--cycle --layout=reverse --no-unicode --bind='tab:down,btab:up,ctrl-d:delete-char,ctrl-g:first,ctrl-q:clear-selection,ctrl-v:select-all,ctrl-c:deselect-all,alt-enter:toggle,ctrl-o:toggle,ctrl-s:toggle,ctrl-t:toggle-all,ctrl-space:toggle-sort,ctrl-y:execute-silent(echo -n {} | xsel -ib)'"
export GOPATH=~/.local/lib/go
export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
#export PAGER="less -R"
export PATH=~"/.local/bin:$PATH"
#export QT_QPA_PLATFORMTHEME=qt5ct
#export RANGER_LOAD_DEFAULT_RC=FALSE
export R_ENVIRON_USER=~/.Renviron
#export TERMINAL=terminal
#export VISUAL=nvim
export XLOGFILE=~"/.local/share/xorg/startx.$XDG_VTNR.log"

# fix for pacdiff to use nvim instead of vim
#export DIFFPROG="nvim -d"
# fix for escape keys in neomutt
export ESCDELAY=0
# fixes for telegram
export TDESKTOP_USE_GTK_FILE_DIALOG=1
export TDESKTOP_I_KNOW_ABOUT_GTK_INCOMPATIBILITY=1
export DESKTOPINTEGRATION=1


## MISCELLANEOUS

if [[ -z "$DISPLAY" && "$XDG_VTNR" -eq 1 ]] ; then
    [[ -f "$XLOGFILE" ]] && { mv -f "$XLOGFILE" "$XLOGFILE.old" ;}
    startx &>"$XLOGFILE"
fi
