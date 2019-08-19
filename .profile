#!/usr/bin/env bash

alias ll='ls -l'
alias la='ls -la'

alias grn='grep -rn'

alias d='docker-compose down'
alias u='docker-compose up'
alias ud='docker-compose up -d'

alias rg='rg -p'
alias less='less -R'
alias emacs='/usr/local/opt/emacs-plus/Emacs.app/Contents/MacOS/Emacs -nw'

if [ -x "$(command -v nvim)" ]; then
  export EDITOR="$(command -v nvim)"
elif [ -x "$(command -v vim)" ]; then
  export EDITOR="$(command -v vim)"
else
  export EDITOR="$(command -v vi)"
fi
export VENV_DIR="$HOME/.local/venvs"

# pyenv shims
if [ -x "$(command -v pyenv)" ]; then
  eval "$(pyenv init -)"
fi

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

  if [ "$VIRTUAL_ENV" != "" ]; then
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

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# fnm
if [ -x "$(command -v fnm)" ]; then
  eval "$(fnm env --multi)"
fi

export FZF_DEFAULT_COMMAND='rg --files'

# start eslint daemon
>/dev/null eslint_d start

ESLINT_PORT=$(cat ~/.eslint_d | cut -d' ' -f1)
ESLINT_TOKEN=$(cat ~/.eslint_d | cut -d' ' -f2)

eslint() {
  echo "$ESLINT_TOKEN $(pwd) $@" | nc localhost $ESLINT_PORT
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
