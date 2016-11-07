# oh-my-zsh settings
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
plugins=(docker git npm vi-mode z)

source $ZSH/oh-my-zsh.sh

# Settings for base16-shell
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Add npm bin to path if it exists
NORMAL_PATH=$PATH
function chpwd() {
  bin_dir="$(npm bin)"
  if [[ -d $bin_dir && $PATH != *"$bin_dir"* ]]; then
    NORMAL_PATH=$PATH
    PATH=$PATH:$bin_dir
  elif [[ ! -d $bin_dir && $PATH = *"node_modules"* ]]; then
    PATH=$NORMAL_PATH
  fi
}

# Aliases
alias serve='python -m SimpleHTTPServer'

alias gcanrc!='gcan! && grbc'
alias gcanpf!='gcan! && gp -f'
alias gcanfp!='gcanpf!'

## Default Variables
export NODE_ENV=development
export PG_HOST=localhost

# Allow for local configuration
if [ -f $HOME/.zshrc.local ]; then
  source $HOME/.zshrc.local
fi

