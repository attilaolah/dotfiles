#!/bin/bash

# US layout
setxkbmap -layout us \
    -option caps:ctrl_modifier

# Key repeat rate
xset r rate 200 25
