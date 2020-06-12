### Misc ###
set -o vi # Vim like navigation in command line

[ -f ~/.fzf.bash ] && source ~/.fzf.bash # Enable fzf in commandline

export GPG_TTY=$(tty)  # Needed for GPG key signing

alias ll="ls -lah"
export CLICOLOR=1

shopt -s cdspell      # autocorrect typos in path names when using `cd`
shopt -s checkwinsize # rezize the windows-size if needed
# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion;

### 1337 PS1 PROMPT ###
COLOR_CYAN="\[\033[0;36m\]"
COLOR_RED="\[\033[0;31m\]"
COLOR_YELLOW="\[\033[0;33m\]"
COLOR_GREEN="\[\033[0;32m\]"
COLOR_OCHRE="\[\033[38;5;95m\]"
COLOR_BLUE="\[\033[0;94m\]"
COLOR_WHITE="\[\033[0;37m\]"
COLOR_RESET="\[\033[0m\]"

function git_status_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ ! $git_status =~ "working tree clean" ]]; then
    echo $COLOR_RED
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo $COLOR_BLUE
  elif [[ $git_status =~ "Your branch is behind" ]] || [[ $git_status =~ "different commits each" ]]; then
    echo $COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo $COLOR_GREEN
  else
    echo $COLOR_OCHRE
  fi
}

### HISTORY ###

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear" # Don't record some commands
# append to history, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
# Useful timestamp format
export HISTTIMEFORMAT='%F %T '

function colored_git_branch {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "$COLOR_GREEN[$(git_status_color)$branch$COLOR_GREEN] "
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "$COLOR_GREEN[$(git_status_color)$commit$COLOR_GREEN] "
  fi
}

function current_virtualenv {
  if [ -z "$VIRTUAL_ENV" ]; then
    return;
  else
     echo " ${COLOR_GREEN}(🐉 `basename $VIRTUAL_ENV`)";
  fi
}

function set_bash_prompt {
  # timestamp
  PS1="$COLOR_BLUE\t"
  # path
  PS1+=" $COLOR_RED\w"
  PS1+="$(current_virtualenv)"
  # git branch/status
  PS1+=" $(colored_git_branch)"
  PS1+="\n"
  PS1+="⚛️"
  PS1+=" $COLOR_RESET "
}

PROMPT_COMMAND=set_bash_prompt
