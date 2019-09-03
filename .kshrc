. ~/.profile

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
    printf "$(dark_theme " $code ") "
  fi
}

export PS1='$(dark_exit_code "$?") $(short_dir "$PWD") $(bold_start)\$$(bold_end) '

# enable arrow keys and all that
set -o emacs

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

mcd() {
  mkdir -p -- "$1" && cd -P -- "$1"
}

export EDITOR=$(command -v nvim)
