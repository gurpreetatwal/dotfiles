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

# Install Programs
## apt
color $green "Installing ZSH"
sudo apt-get install zsh -y

# System Setup
## ZSH Setup
if [[ $SHELL != *"zsh"* ]]; then
  color $green "Setting ZSH to be the default shell"
  chsh -s "$(which zsh)"
fi

# Install pathogen
## TODO only create dirs if they don't exist
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Symlink config files to home
## TODO ask override if symlink fails
## TODO find a better way to do this than an array
color $green "Linking config files to ~/"
for file in "${FILES[@]}"; do
	ln -s $DIR/$file $HOME
done

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
