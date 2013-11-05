source "$HOME/.oh-my-zsh/templates/zshrc.zsh-template"

plugins=(cp go golang git github gitignore python tmux)

setopt appendhistory autocd extendedglob notify
bindkey -e

autoload completeinword
zstyle :compinstall filename '/home/aatiis/.zshrc'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'

autoload select-word-style
select-word-style shell

autoload -Uz compinit
compinit

if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls='ls -F --color=auto'
else
  alias ls='ls -F'
fi

setopt incappendhistory 
setopt sharehistory
setopt extendedhistory

# superglobs
setopt extendedglob
unsetopt caseglob

setopt interactivecomments # pound sign in interactive prompt

# Generic aliases
alias o="xdg-open"
alias ll="ls -lah"
alias l="ls -lh"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias c="curl --dump-header -"
alias gf="gofmt -w ."

# Git aliases
alias g='git status'
alias gb='git branch'
alias gd='git diff'
alias gdm='git diff master'
alias gl='git log'
alias ga='git add'
alias gaa='git add -p .'
alias gco='git checkout'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gba='git branch -a'
alias gp='git push'
alias gre='git rev-parse HEAD'
alias eg='$EDITOR .git/config'
alias ungit="find . -name '.git' -exec rm -rf {} \;"
disable -a gg
function gg() {
    git commit -m "$*"
}
