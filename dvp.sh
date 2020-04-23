#!/bin/bash

# DVP layout
setxkbmap -layout us \
    -variant dvp \
    -option altwin:meta_win \
    -option caps:ctrl_modifier \
    -option compose:ralt \
    -option keypad:atm \
    -option kpdl:semi \
    -option numpad:shift3
