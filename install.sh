#!/bin/bash

# Setup
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(.gitconfig .tmux.conf .bashrc)

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
