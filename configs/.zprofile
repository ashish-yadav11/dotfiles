# autostart x on login
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]] ; then
  startx &>"$HOME/.local/share/xorg/startx.$XDG_VTNR.log"
fi
