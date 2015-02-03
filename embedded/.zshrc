source $HOME/.profile

unsetopt nomatch
setopt appendhistory autocd extendedglob notify
bindkey -e

autoload completeinword
zstyle :compinstall filename "/home/aatiis/.zshrc"
zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}"
zstyle ":completion:*:killall:*" command "ps -u $USER -o cmd"

autoload select-word-style
select-word-style shell

autoload -Uz compinit
compinit

setopt incappendhistory
setopt sharehistory
setopt extendedhistory

# superglobs
setopt extendedglob
unsetopt caseglob

setopt interactivecomments # pound sign in interactive prompt

# Aliases
if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls="ls -F --color=auto"
else
  alias ls="ls -F"
fi
alias l="ls -lh"
alias ll="ls -la"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias c="curl -s --dump-header /dev/stderr"

# Below is a custom theme, based on "sorin".
local prompt_jobs="%(1j.%{$fg[yellow]%}%j%{$reset_color%}%{$fg[red]%}z%{$reset_color%} .)"
local prompt_host="%{$fg[cyan]%}%m%{$reset_color%}"
local prompt_root="%(!.%{$fg_bold[red]%}#.%{$fg[green]%}$)%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..=)%{$reset_color%}"

PROMPT="${prompt_jobs}${prompt_host}$(git_prompt_info) %~ ${prompt_root} "
RPROMPT="${return_status}%*"
