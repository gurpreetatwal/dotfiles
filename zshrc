# oh-my-zsh settings
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
plugins=(docker git npm vi-mode z)

source $ZSH/oh-my-zsh.sh

# Settings for base16-shell
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Add ~/bin to path
PATH=$PATH:~/bin

#  Jumps to temp directory or if given a name, creates that directory and jumps to it
function temp {
  whereto="$HOME/temp"
  if [[ $# == 1 ]]; then
    whereto="$whereto/$1"
    mkdir "$whereto"
  fi
  cd "$whereto"
}

# Aliases
alias serve='browser-sync start -s'
alias gl='git pull --prune'
alias gpf='git push -f'
alias gcanrc!='git commit --amend --no-edit && git rebase --continue'
alias gcanpf!='git commit --amend --no-edit && git push -f'
alias gcanfp!='gcanpf!'
alias ag='ag --path-to-agignore ~/.agignore'

## Default Variables
export NODE_ENV=development
export PG_HOST=localhost
export SPACESHIP_DOCKER_SHOW=false

eval "$(thefuck --alias ugh)"

# Windows Subsytem for Linux
if [[ "$(uname -r)" = *"Microsoft" ]]; then
  export DOCKER_HOST=tcp://:2375
  if [ "$(umask)" = "000" ]; then
    umask 022
  fi
fi

# Allow for local configuration
if [ -f $HOME/.zshrc.local ]; then
  source $HOME/.zshrc.local
fi
