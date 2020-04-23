#!/bin/bash

# DVP layout
setxkbmap -layout us \
    -variant dvp \
    -option caps:ctrl_modifier \
    -option model:thinkpad \
    -option compose:ralt \
    -option keypad:atm \
    -option numpad:shift3 \
    -option altwin:meta_win \
    -option kpdl:semi
