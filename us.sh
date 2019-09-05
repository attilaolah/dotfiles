#!/bin/bash

# US layout
setxkbmap -layout us

# Caps Lock = Esc.
MYMODMAP="$HOME/.Xmodmap"
if [ -f "$MYMODMAP" ]; then
    xmodmap "$MYMODMAP"
fi

# Key repeat rate
xset r rate 200 25
