# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="sorin"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(cp go git gitignore python)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
unsetopt nomatch
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

setopt incappendhistory
setopt sharehistory
setopt extendedhistory

# superglobs
setopt extendedglob
unsetopt caseglob

setopt interactivecomments # pound sign in interactive prompt

# Git aliases
alias g='git status'
alias ga='git add'
alias gaa='git add -p .'
alias gb='git branch -av'
alias gc='git commit -v'
alias gd='git diff'
alias gp='git push'
alias gr='git remote -v'
alias ungit="find . -name '.git' -exec rm -rf {} \;"
disable -a gg
function gg() {
    git commit -m "$*"
}
alias gl='git log --graph --pretty=format:"%C(bold red)%h%C(reset)%C(yellow)%d%C(reset) %C(red)(%cr)%C(reset) %s — %C(blue)%ae%C(reset)" --abbrev-commit'

# More aliases
if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls='ls -F --color=auto'
else
  alias ls='ls -F'
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

# Below is a custom theme, based on "sorin".
MODE_INDICATOR="%{$fg_bold[red]%}❮%{$reset_color%}%{$fg[red]%}❮❮%{$reset_color%}"

local prompt_jobs="%(1j.%{$fg[yellow]%}%j%{$reset_color%}%{$fg[red]%}z%{$reset_color%} .)"
local prompt_host="%{$fg[cyan]%}%m%{$reset_color%}"
local prompt_root="%(!.%{$fg_bold[red]%}#.%{$fg[green]%}$)%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..=)%{$reset_color%}"

PROMPT='${prompt_jobs}${prompt_host}$(git_prompt_info) %~ ${prompt_root} '
RPROMPT="${return_status}%*"

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}git%{$reset_color%}:%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}…%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

source $HOME/.profile
