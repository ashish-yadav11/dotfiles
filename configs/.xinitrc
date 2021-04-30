#!/bin/sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap -quiet "$sysmodmap"
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap -quiet "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# redshift
time=$(date +%H%M)
if [ "$time" -ge 2200 ] || [ "$time" -lt 0600 ] ; then
    redshift -PO 4500
fi

# fixes for telegram
export TDESKTOP_USE_GTK_FILE_DIALOG=1
export TDESKTOP_I_KNOW_ABOUT_GTK_INCOMPATIBILITY=1
export DESKTOPINTEGRATION=1

# fix for java programs in dwm
wmname LG3D
export _JAVA_AWT_WM_NONREPARENTING=1

xwallpaper --stretch /home/ashish/.config/wall* &
pidof -s /usr/lib/polkit-kde-authentication-agent-1 >/dev/null 2>&1 ||
    /usr/lib/polkit-kde-authentication-agent-1 &
pidof -s /usr/bin/nm-applet >/dev/null 2>&1 || nm-applet &
clipdaemon &
dsblocks &
pidof -sx /home/ashish/.scripts/pulse_daemon.sh >/dev/null 2>&1 ||
    /home/ashish/.scripts/pulse_daemon.sh &
unclutter &

#exec valgrind --leak-check=full dwm
exec dwm
