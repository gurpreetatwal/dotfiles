source $ZSH/oh-my-zsh.sh

# oh-my-zsh settings
ZSH_THEME="spaceship"
plugins=(git vi-mode npm docker)

# Aliases
alias serve='python -m SimpleHTTPServer'

alias gcanrc!='gcan! && grbc'
alias gcanpf!='gcan! && gp -f'
alias gcanfp!='gcanpf!'

## Default Variables
export ZSH=$HOME/.oh-my-zsh
export NODE_ENV=development
export PG_HOST=localhost

# Allow for local configuration
if [ -f $HOME/.zshrc.local ]; then
  source $HOME/.zshrc.local
fi
