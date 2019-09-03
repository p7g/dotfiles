#!/usr/bin/env bash

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

if [ -x "$(command -v nvim)" ]; then
  export EDITOR="$(command -v nvim)"
elif [ -x "$(command -v vim)" ]; then
  export EDITOR="$(command -v vim)"
else
  export EDITOR="$(command -v vi)"
fi
export VENV_DIR="$HOME/.local/venvs"

rgl() {
  if [[ -t 1 ]]; then
    rg -p "$@" | less -M +Gg
    return $?
  fi
  rg -p "$@"
  return $?
}

p() {
  if [ "$#" -ne 1 ]; then
    >&2 printf "Expected 1 argument\n"
    return 1
  fi

  if [ "$VIRTUAL_ENV" != '' ]; then
    >&2 printf "Already in a virtualenv \"$(basename "$VIRTUAL_ENV")\"\n"
    return 2
  fi

  if ! [ -d "$VENV_DIR/$1" ]; then
    >&2 printf "Virtualenv \"$1\" not found\n"
    return 3
  fi

  source "$VENV_DIR/$1/bin/activate"
}

m() {
  "$(pwd)/manage.py" "$@"
}

if [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

. "$HOME/.asdf/asdf.sh"

# if the terminal supports color...
if [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then

  # make command output colorful
  if ls --color=auto -d / >/dev/null 2>&1; then
    ls() { command ls --color=auto "$@"; }
  fi
  if grep --color=auto -q X '<<<X' 2>/dev/null; then
    grep() { command grep --color=auto "$@"; }
  fi
  if ggrep --color=auto -q X '<<<X' 2>/dev/null; then
    ggrep() { command ggrep --color=auto "$@"; }
  fi

fi

# find escape sequence to change terminal window title
case "$TERM" in
  (xterm|xterm[+-]*|gnome|gnome[+-]*|putty|putty[+-]*)
    _tsl='\033]0;' _fsl='\033\\' ;;
  (cygwin)
    _tsl='\033];' _fsl='\a' ;;
  (*)
    _tsl=$( (tput tsl 0; echo) 2>/dev/null |
    sed -e 's;\\;\\\\;g' -e 's;;\\033;g' -e 's;;\\a;g' -e 's;%;%%;g')
    _fsl=$( (tput fsl  ; echo) 2>/dev/null |
    sed -e 's;\\;\\\\;g' -e 's;;\\033;g' -e 's;;\\a;g' -e 's;%;%%;g') ;;
esac
# if terminal window title can be changed...
if [ "$_tsl" ] && [ "$_fsl" ]; then

  # set terminal window title on each prompt
  _set_term_title()
  if [ -t 2 ]; then
    printf "$_tsl"'%s@%s:%s'"$_fsl" "${LOGNAME}" "${HOSTNAME%%.*}" \
      "${${PWD:/$HOME/\~}/#$HOME\//\~\/}" >&2
  fi
  PROMPT_COMMAND=("$PROMPT_COMMAND" '_set_term_title') # for bash and yash
  precmd() { eval "$PROMPT_COMMAND"; } # for zsh

  # reset window title when changing host or user
  ssh() {
    if [ -t 2 ]; then printf "$_tsl"'ssh %s'"$_fsl" "$*" >&2; fi
    command ssh "$@"
  }
  su() {
    if [ -t 2 ]; then printf "$_tsl"'su %s'"$_fsl" "$*" >&2; fi
    command su "$@"
  }
  sudo() {
    if [ -t 2 ]; then printf "$_tsl"'sudo %s'"$_fsl" "$*" >&2; fi
    command sudo "$@"
  }

fi

alias source='.'

alias ll='ls -l'
alias la='ls -la'

alias grn='grep -rn'

alias d='docker-compose down'
alias u='docker-compose up'
alias ud='docker-compose up -d'

alias rg='rg -p'
alias less='less -R'
alias emacs='/usr/local/opt/emacs-plus/Emacs.app/Contents/MacOS/Emacs -nw'
