#!/bin/bash

# DVP layout
setxkbmap -layout us \
    -variant dvp \
    -option altwin:meta_win \
    -option caps:escape \
    -option compose:ralt \
    -option keypad:atm \
    -option kpdl:semi \
    -option numpad:shift3
