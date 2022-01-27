setopt ignore_eof

bindkey -e

export PS1='%(?..%S %? %s) %1~ %# '

sp() {
  source "$HOME/.profile"
}

sp

autoload edit-command-line; zle -N edit-command-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

export GPG_TTY=$(tty)

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"
