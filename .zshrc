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

function zle-line-init zle-keymap-select {
  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
  export RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
  zle reset-prompt
}

setopt PROMPT_SUBST
bindkey -v
export KEYTIMEOUT=1
zle -N zle-line-init
zle -N zle-keymap-select

# export PS1='%(?..%? )%1~ %# '
export PS1='$(dark_exit_code "$?") $(short_dir "$PWD") $(bold_start)%#$(bold_end) '

sp() {
  source "$HOME/.profile"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
