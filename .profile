#!/usr/bin/env bash

if [ -x "$(command -v nvim)" ]; then
  export EDITOR="$(command -v nvim)"
elif [ -x "$(command -v vim)" ]; then
  export EDITOR="$(command -v vim)"
else
  export EDITOR="$(command -v vi)"
fi
export VENV_DIR="$HOME/.local/venvs"

# source a virtualenv
p() {
  venv_name=$1

  if [ -z "$1" ]; then
    venv_name=$(basename $PWD)
  fi

  if ! [ -d "$VENV_DIR/$venv_name" ]; then
    >&2 printf 'Virtualenv "%s" not found\n' "$venv_name"
    return 3
  fi

  source "$VENV_DIR/$venv_name/bin/activate"
}

find_managepy() {
  local cur
  cur='.'
  while ! [ -e "$cur/manage.py" ]; do
    cur="$(realpath "../$cur")"
    if [ "$cur" = '/' ]; then
      >&2 echo 'No manage.py found'
      return 1
    fi
  done
  echo "$cur/manage.py"
}

# shorthand for django ./manage.py
m() {
  "$(find_managepy)" "$@"
}

myvi() {
  local ocols=$(tput cols)
  stty columns 160
  \vi "$@"
  stty columns $ocols
}

alias vi="myvi"

dcw() {
  opts=()
  for c in "$@"; do
    opts+=("--scale $c=0")
  done
  eval "docker-compose up -d ${opts[*]}"
  return $?
}

if >/dev/null command -v rpg-cli; then
  try_unalias() {
    if alias "$1" >/dev/null; then
      unalias "$1"
    fi
  }

  try_unalias cd
  alias rpg=rpg-cli

  cd() {
    rpg-cli cd "$@"
    builtin cd "$(rpg-cli pwd)"
  }

  try_unalias ls

  ls() {
    command ls "$@"
    if [ $# -eq 0 ]; then
      rpg-cli cd -f .
      rpg-cli ls
    fi
  }

  battle="rpg-cli cd -f . && rpg-cli battle"
  alias rm="$battle && rm"
  alias rmdir="$battle && rmdir"
  alias mkdir="$battle && mkdir"
  alias touch="$battle && touch"
  alias mv="$battle && mv"
  alias cp="$battle && cp"
  alias chown="$battle && chown"
  alias chmod="$battle && chmod"
fi

export FZF_DEFAULT_OPTS='--color=bw'
if >/dev/null command -v rg; then
  export FZF_DEFAULT_COMMAND=$'rg --glob \'!**/node_modules\' --files'
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

if ! command -v sudoedit >/dev/null; then
  alias sudoedit='sudo -e'
fi

alias dc='docker-compose'

alias rg=$'rg --glob \'!**/node_modules\''

alias fvim='__VIM_MODE=fast nvim'

alias py-json='python -c "import sys, json; print(json.dumps(eval(sys.stdin.read())))"'

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.asdf/asdf.sh"

export PATH="/usr/local/opt/llvm/bin:$PATH"

alias luajit="$(which luajit-2.1.0-beta3)"

# Default WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
