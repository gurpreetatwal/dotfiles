#!/bin/bash

# Script Setup
## Global Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(gitconfig gitignore.global tern-project tmux.conf vimrc zshrc)
TMUX_VERSION=2.3

## Helper for colored output. Usage: color $red "Error!"
black=30 red=31 green=32 brown=33 blue=34 purple=35 cyan=36 gray=37
color() {
  echo -e "\e[1;$1m$2\e[0m"
}

# use apt if its available
which apt > /dev/null && apt=apt || apt=apt-get
installif() {
  for pkg in $@; do
    dpkg -s $pkg | grep -q 'Status: install ok installed' && continue;
    color $green "Install $pkg"
    sudo $apt install -q $pkg
  done
}

# Install Programs
## apt
installif zsh
installif build-essential cmake python-dev python3-dev

## npm
color $green "updating global npm packages"
sudo npm update --global npm bower bunyan nodemon eslint eslint_d

# System Setup
## ZSH Setup
if [[ $SHELL != *"zsh"* ]]; then
  color $green "Setting ZSH to be the default shell"
  chsh -s "$(which zsh)"
fi

# Symlink config files to home
## TODO ask override if symlink fails
## TODO find a better way to do this than an array
color $green "Linking config files to ~/"
for file in "${FILES[@]}"; do
  LINK_NAME="$HOME/.$file"
  if [[ ! -h "$LINK_NAME" || $(readlink "$LINK_NAME") != "$DIR/$file" ]]; then
    [[ -e $LINK_NAME ]] && mv $LINK_NAME "$LINK_NAME.bak"
    ln -s "$DIR/$file" "$LINK_NAME"
  fi
done

# install latest tmux
if [[ $(tmux -V) != *"$TMUX_VERSION"* ]]; then
  color $green "Upgrading tmux to $TMUX_VERSION"
  curl -LSsf https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz | tar -xz -C /tmp
  installif libevent-dev ncurses-dev
  pushd /tmp/tmux-$TMUX_VERSION
  ./configure && make > /dev/null
  sudo make install
  popd
fi

# Install vim plug
if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
  color $green "Installing vim plug"
  curl -LSsfo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install and configure vim plugins
vim +PlugUpdate +qa

# Install oh-my-zsh
if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

if [[ ! -d "$ZSH" ]]; then
  color $green "Installing ZSH"
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
fi

if [[ ! -e ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme ]]; then
  color $green "Installing ZSH spaceship theme"
  curl -LSsfo ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme --create-dirs https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/spaceship.zsh
fi

if [[ $SHELL != "zsh" ]]; then
  zsh
fi
