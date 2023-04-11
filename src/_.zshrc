# Load the user profile.
# This will set up the $PATH to be managed by home-manager.
source "${HOME}/.profile"

# Start fish.
WHICH_FISH="$(which fish)"
if [[ "$-" =~ i && -x "${WHICH_FISH}" && ! "${SHELL}" -ef "${WHICH_FISH}" ]]; then
  # Safeguard to only activate fish for interactive shells and only if fish
  # shell is present and executable. Verify that this is a new session by
  # checking if ${SHELL} is set to the path to fish. If it is not, we set
  # ${SHELL} and start fish.

  # If this is not a new session, the user probably typed 'zsh' into their
  # console and wants zsh, so we skip this.
  exec env SHELL="${WHICH_FISH}" "${WHICH_FISH}" -i
fi

## ZSH config.
## This is only used when staying in 'zsh' instead of 'fish'.

unsetopt nomatch
setopt autocd notify
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
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fancy-ctrl-z
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

# History
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh

HISTSIZE=50000
SAVEHIST=10000
[ -z "${HISTFILE}" ] && HISTFILE="${HOME}/.zsh_history"

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# Prompt

autoload -U colors && colors

local prompt_jobs="%(1j.%{$fg[yellow]%}%j%{$reset_color%}%{$fg[red]%}z%{$reset_color%} .)"
local prompt_host="%{$fg[cyan]%}%m%{$reset_color%}"
local prompt_root="%(!.%{$fg_bold[red]%}#.%{$fg[green]%}$)%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..=)%{$reset_color%}"

PROMPT="${prompt_jobs}${prompt_host} %~ ${prompt_root} "
RPROMPT="${return_status}%*"

# Create a zkbd compatible hash.
# To add other keys to this hash, see: man 5 terminfo.
# Source: https://wiki.archlinux.org/index.php/Zsh#Key_bindings.
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# Setup the key accordingly.
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete


# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
