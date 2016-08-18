#!/bin/bash

# Colored output
black=30 red=31 green=32 brown=33 blue=34 purple=35 cyan=36 gray=37
color() {
  echo -e "\e[1;$1m$2\e[0m"
}

# Setup
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(.gitconfig .tmux.conf .bashrc .vimrc)

# Install pathogen
## TODO only create dirs if they don't exist
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Symlink config files to home
## TODO ask override if symlink fails
## TODO find a better way to do this than an array
for file in "${FILES[@]}"; do
	ln -s $DIR/$file $HOME
done
