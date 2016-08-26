#!/bin/bash

# Script Setup
## Global Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(.gitconfig .tmux.conf .bashrc .vimrc)

## Helper for colored output. Usage: color $red "Error!"
black=30 red=31 green=32 brown=33 blue=34 purple=35 cyan=36 gray=37
color() {
  echo -e "\e[1;$1m$2\e[0m"
}

installif() {
  dpkg -s $1 > /dev/null
  if [[ $? != 0 ]]; then
    color $green "Install $1"
    sudo apt-get install -y $1
  fi
}

# Install Programs
## apt
installif zsh
BUILD_TOOLS=(build-essential cmake python-dev python3-dev)
installif BUILD_TOOLS

# System Setup
## ZSH Setup
if [[ $SHELL != *"zsh"* ]]; then
  color $green "Setting ZSH to be the default shell"
  chsh -s "$(which zsh)"
fi

# Install vim plug
if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
  color $green "Installing vim plug"
  curl -LSsfo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install and configure vim plugins
vim +PlugUpdate +qa

# Symlink config files to home
## TODO ask override if symlink fails
## TODO find a better way to do this than an array
color $green "Linking config files to ~/"
for file in "${FILES[@]}"; do
  ln -s $DIR/$file $HOME
done

# Install oh-my-zsh
if [[ ! -e ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi