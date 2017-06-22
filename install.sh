#!/bin/bash

# Script Setup
## Global Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(agignore gitconfig gitignore.global tern-project tmux.conf vimrc zshrc)
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
    sudo $apt install -q -y $pkg
  done
}

# link source ~/.dest
link() {
  SOURCE=$1; DEST=$2
  if [[ ! -h "$DEST" || $(readlink "$DEST") != "$DIR/$SOURCE" ]]; then
    [[ -e $DEST ]] && mv $DEST "$DEST.bak"
    ln -s "$DIR/$SOURCE" "$DEST"
  fi
}

# Install Programs
## apt
installif zsh silversearcher-ag
installif build-essential cmake python-dev python3-dev

## npm
color $green "updating global npm packages"
sudo npm install --global npm bower browser-sync bunyan gulp eslint_d nodemon
sudo npm update --global bower browser-sync bunyan gulp eslint_d nodemon

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
  link $file $HOME/.$file
done

# Neovim
mkdir -p ~/.config/nvim
link "vimrc" ~/.config/nvim/init.vim

# install base16-shell
if [[ ! -e ~/.config/base16-shell ]]; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
  find  ~/.config/base16-shell/scripts -type f -exec chmod 744 {} \;
  ~/.config/base16-shell/scripts/base16-google-dark.sh
fi

# install tmux plugin manager
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

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

if [[ ! "$(which thefuck)" ]]; then
  installif python3-dev python3-pip
  sudo -H pip3 install --upgrade pip setuptools thefuck
fi

if [[ ! -d "$ZSH" ]]; then
  color $green "Installing ZSH"
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
fi

if [[ ! -e ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme ]]; then
  color $green "Installing ZSH spaceship theme"
  curl -LSsfo ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme --create-dirs https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/spaceship.zsh
fi

if [[ $SHELL != *"zsh"* ]]; then
  zsh
fi
