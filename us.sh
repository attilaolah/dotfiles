#!/bin/bash

# US layout
setxkbmap -layout us \
    -option caps:escape

# Key repeat rate
xset r rate 200 25
