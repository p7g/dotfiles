bold_start() {
  printf "$(tput bold)"
}

bold_end() {
  printf "$(tput sgr0)"
}

dark_theme_start() {
  printf "$(tput smso)"
}

dark_theme_end() {
  printf "$(tput rmso)"
}

bold_text() {
  printf "$(bold_start)$@$(bold_end)"
}

dark_theme() {
  printf "$(dark_theme_start)$@$(dark_theme_end)"
}

short_dir() {
  if [ "$1" = "$HOME" ]; then
    printf '~'
  else
    printf "$(basename "$1")"
  fi
}

exit_code() {
  if [ "$1" -ne '0' ]; then
    printf "$1"
  fi
}

dark_exit_code() {
  code=$(exit_code $1)
  if [ "$code" != '' ]; then
    printf "$(dark_theme " $code ")"
  fi
}

bindkey -e

branch() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if ! git diff --quiet; then
      dirty='*'
    fi
    echo "$(git rev-parse --abbrev-ref HEAD)$dirty"
  fi
}

export PS1='%(?..%S %? %s) %1~ %# '
# export RPROMPT='$(_git_prompt)'

sp() {
  source "$HOME/.profile"
}

sp

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

export GPG_TTY=$(tty)

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export CXXFLAGS='-stdlib=libc++'
export PATH="/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"
