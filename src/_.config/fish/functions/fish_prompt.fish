## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

## Function to show current status
function show_ssh -d "Function to show the current status"
  if [ -n "$SSH_CLIENT" ]
    prompt_segment blue white "SSH"
  end
end

## Function to show current shell level
function show_shlvl -d "Function to show the current shell level"
  set -l colour green
  if [ $RETVAL -ne 0 ]
    set colour red
  end
  prompt_segment normal white "L"
  prompt_segment normal $colour "$SHLVL"
  prompt_segment normal white " "
end

function show_virtualenv -d "Show active Python virtual environments"
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    prompt_segment normal white " [$venvname]"
  end
end

## Show user if not in default users
function show_user -d "Show user"
  if not contains $USER $default_user; or test -n "$SSH_CLIENT"
    set -l host (hostname -s)
    set -l who (whoami)
    prompt_segment normal yellow "$who"

    # Skip @ bit if hostname == username
    if [ "$who" != "$host" ]
      prompt_segment normal white "@"
      prompt_segment normal green "$host"
    end
  end
end

function _set_venv_project --on-variable VIRTUAL_ENV
    if test -e $VIRTUAL_ENV/.project
        set -g VIRTUAL_ENV_PROJECT (cat $VIRTUAL_ENV/.project)
    end
end

# Show directory
function show_pwd -d "Show the current directory"
  set -l pwd
  if [ (string match -r '^'"$VIRTUAL_ENV_PROJECT" $PWD) ]
    set pwd (string replace -r '^'"$VIRTUAL_ENV_PROJECT"'($|/)' '≫ $1' $PWD)
  else
    set pwd (prompt_pwd)
  end
  prompt_segment normal blue " $pwd "
end

# Show prompt w/ privilege cue
function show_prompt -d "Shows prompt with cue for current priv"
  set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
    prompt_segment red white "! "
    set_color normal
    echo -n -s " "
  else
    prompt_segment normal white "\$ "
    end

  set_color normal
end

## SHOW PROMPT
function fish_prompt
  set -g RETVAL $status
  show_ssh
  show_shlvl
  show_user
  # No need, since `source bin/activate.fish` already shows this.
  #show_virtualenv
  show_pwd
  show_prompt
end
