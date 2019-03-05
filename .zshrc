unsetopt nomatch
setopt appendhistory histignorealldups autocd notify
bindkey -e

_cli_fg() {
  fg 2>/dev/null || true
}
zle -N _cli_fg
bindkey '^Z' _cli_fg

autoload completeinword
zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}"
zstyle ":completion:*:killall:*" command "ps -u $USER -o cmd"

autoload select-word-style
select-word-style shell

autoload -Uz compinit
compinit

setopt incappendhistory
setopt sharehistory
setopt extendedhistory

# Enable superglobs:
setopt extendedglob
unsetopt caseglob

setopt interactivecomments # pound sign in interactive prompt

# Aliases for git:
alias g="git status"

alias ga="git add -p ."
alias gb="git branch -avv"
alias gc="git commit -v"
alias gd="git diff"
alias gl="git log --graph --pretty=format:'%C(bold red)%h%C(reset)%C(yellow)%d%C(reset) %C(red)(%cr)%C(reset) %s — %C(blue)%ae%C(reset)' --abbrev-commit"
alias gp="git push"
alias gr="git remote -v"

function gg() {
  git commit -m "$*"
}

alias ungit="find . -name '.git*' -exec rm -rf {} \;"
alias unbranch="git remote prune origin && git branch --merged | grep -v \"\*\" | xargs -n 1 git branch -d"

# More aliases
if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls="ls -F --color=auto"
else
  alias ls="ls -F"
fi
alias o="xdg-open"
alias l="ls -lh"
alias ll="ls -la"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias c="curl -s --dump-header /dev/stderr"
alias gf="gofmt -w ."

# Fancy Ctrl+Z plugin from oh-my-zsh:
# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/fancy-ctrl-z
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Prompt

autoload -U colors && colors

local prompt_jobs="%(1j.%{$fg[yellow]%}%j%{$reset_color%}%{$fg[red]%}z%{$reset_color%} .)"
local prompt_host="%{$fg[cyan]%}%m%{$reset_color%}"
local prompt_root="%(!.%{$fg_bold[red]%}#.%{$fg[green]%}$)%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..=)%{$reset_color%}"

PROMPT="${prompt_jobs}${prompt_host} %~ ${prompt_root} "
RPROMPT="${return_status}%*"

source $HOME/.zshrc_work
source $HOME/.profile
