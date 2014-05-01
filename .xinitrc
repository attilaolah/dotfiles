#!/bin/bash

# Java apps are broken and need a WM on their hardcoded list. For maximum
# irony, you should impersonate LG3D, a window manager written by Sun in Java.
# Available from http://tools.suckless.org/wmname
wmname LG3D

# DVP layout
setxkbmap -layout us \
    -variant dvp \
    -option compose:ralt \
    -option keypad:atm \
    -option numpad:shift3 \
    -option altwin:meta_win \
    -option kpdl:semi

# Caps Lock = Esc.
MYMODMAP="$HOME/.Xmodmap"
if [ -f "$MYMODMAP" ]; then
    xmodmap "$MYMODMAP"
fi

# Nice cursor
xsetroot -cursor_name left_ptr

# Key repeat rate
xset r rate 200 25

# Composition
#xcompmgr -c -C -l -2 -t -2 -r 2 -o .75 &

# Start Wingo
exec dbus-launch wingo
