#!/bin/sh
userresources=~/.Xresources
usermodmap=~/.Xmodmap
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
{
time="$(date +%H%M)"
if [ "$time" -ge 2200 ] || [ "$time" -lt 0600 ] ; then
    redshift -PO 4500
fi
} &

# fix for java programs in dwm
wmname LG3D &
export _JAVA_AWT_WM_NONREPARENTING=1

xwallpaper --stretch /home/ashish/.config/wall* &
{
pidof -sq /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 ||
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1
} &
{
pidof -sq /usr/bin/nm-applet ||
    nm-applet
} &
{
pidof -sq /usr/bin/dunst ||
    dunst
} &
dsblocks &
{
pidof -sqx /home/ashish/.scripts/pulse_daemon.sh ||
    /home/ashish/.scripts/pulse_daemon.sh
} &
clipdaemon &
playerctld daemon &
unclutter &
adb start-server &
#gebaard &
savewintitles -d &
/home/ashish/.scripts/ytmsclu-daemon.sh &

#exec valgrind --leak-check=full dwm
exec dwm
