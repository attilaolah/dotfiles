#!/bin/bash

# Java apps are broken and need a WM on their hardcoded list. For maximum
# irony, you should impersonate LG3D, a window manager written by Sun in Java.
# Available from http://tools.suckless.org/wmname
wmname LG3D

# Auto-start
nm-applet &
stalonetray &

# ThinkPad X200 Tablet ICC profile
xcalib -d :0 ~/.color/icc/TPLCD.ICM

# Nice cursor
xsetroot -cursor_name left_ptr

# DVP layout
setxkbmap -layout us \
    -variant dvp \
    -option model:thinkpad \
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

# Key repeat rate
xset r rate 200 25

# Start Wingo
exec dbus-launch wingo
