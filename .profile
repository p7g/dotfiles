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

# pipe ripgrep output into less
rgl() {
  if [[ -t 1 ]]; then
    rg -p "$@" | less -M +Gg
    return $?
  fi
  rg -p "$@"
  return $?
}

# source a virtualenv
p() {
  venv_name=$1

  if [ -z "$1" ]; then
    venv_name=$(basename $PWD)
  fi

  if ! [ -d "$VENV_DIR/$venv_name" ]; then
    >&2 printf "Virtualenv \"$1\" not found\n"
    return 3
  fi

  source "$VENV_DIR/$venv_name/bin/activate"
}

# shorthand for django ./manage.py
m() {
  "$(pwd)/manage.py" "$@"
}

myvi() {
  local ocols=$(tput cols)
  stty columns 160
  \vi "$@"
  stty columns $ocols
}

tmux-session() {
  if tmux has-session -t fellow; then
    tmux attach-session -t fellow
    return $?
  fi

  tmux new-session -c "$HOME/code/fellow/web" -s fellow -n client \; \
    send-keys 'npm run dev' C-m \; \
    new-window -n server \; \
    send-keys 'cd "$HOME/code/fellow" && p fellow' C-m \; \
    send-keys 'dc up -d --scale celery=0 && m runserver 8080' C-m \; \
    new-window -n celery \; \
    send-keys 'cd "$HOME/code/fellow" && p fellow' C-m \; \
    send-keys 'while [ -z "$(docker-compose ps -q db)" ] || [ -z "$(docker ps -q --no-trunc | grep "$(docker-compose ps -q db)")" ]; do' \
              '  sleep 1; ' \
              'done; ' \
              'celery worker --app=server.fellow.celery --loglevel debug --queues=celery,realtime,background --beat' C-m \; \
    new-window \; \
    send-keys 'cd "$HOME/code/fellow" && p fellow' C-m \; \
    new-window -n nvim \; \
    send-keys 'cd "$HOME/code/fellow" && p fellow' C-m \; \
    send-keys 'nvim' C-m
}

alias vi="myvi"

if [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND=$'rg --glob \'!**/node_modules\' --files'
fi

. "$HOME/.asdf/asdf.sh"

# if the terminal supports color...
if [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then

  # make command output colorful
  if ls --color=auto -d / >/dev/null 2>&1; then
    alias ls='ls --color=auto'
  fi
  if grep --color=auto -q X '<<<X' 2>/dev/null; then
    alias grep='grep --color=auto'
  fi
  if ggrep --color=auto -q X '<<<X' 2>/dev/null; then
    alias ggrep='ggrep --color=auto'
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

if ! command -v sudoedit >/dev/null; then
  alias sudoedit='sudo -e'
fi

alias source='.'

alias ll='ls -l'
alias la='ls -la'

alias grn='grep -rn'

alias dc='docker-compose'

alias rg=$'rg --glob \'!**/node_modules\''
alias rgp='rg --pcre2'
alias less='less -R'
alias emacs='/usr/local/opt/emacs-plus/Emacs.app/Contents/MacOS/Emacs -nw'

alias fvim='__VIM_MODE=fast nvim'

alias py-json='python -c "import sys, json; print(json.dumps(eval(sys.stdin.read())))"'

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/bin:$PATH"

. $HOME/.asdf/asdf.sh
