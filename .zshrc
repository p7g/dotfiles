setopt ignore_eof

bindkey -e

export PS1='%(?..%S %? %s) %1~ %# '

source "$HOME/.profile"

autoload edit-command-line; zle -N edit-command-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export GPG_TTY=$(tty)
