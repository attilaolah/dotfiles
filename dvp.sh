#!/bin/bash

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